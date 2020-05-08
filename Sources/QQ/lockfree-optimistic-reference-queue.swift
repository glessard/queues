//
//  lockfree-optimistic-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import CAtomics

/// Lock-free queue with node recycling
///
/// Note that node recycling is necessary with this algorithm.
/// A non-recycling algorithm is possible by using hazard pointers,
/// or possibly by relying on ARC.
///
/// Lock-free queue algorithm adapted from Edya Ladan-Mozes and Nir Shavit,
/// "An optimistic approach to lock-free FIFO queues",
/// Distributed Computing (2008) 20:323-341; DOI 10.1007/s00446-007-0050-0
///
/// See also:
/// Proceedings of the 18th International Conference on Distributed Computing (DISC) 2004
/// http://people.csail.mit.edu/edya/publications/OptimisticFIFOQueue-DISC2004.pdf

final public class OptimisticLockFreeReferenceQueue<T: AnyObject>: QueueType
{
  public typealias Element = T
  typealias Node = LockFreeNode

  let storage = UnsafeMutablePointer<AtomicTaggedMutableRawPointer>.allocate(capacity: 3)
  private var head: UnsafeMutablePointer<AtomicTaggedMutableRawPointer> { return storage+0 }
  private var tail: UnsafeMutablePointer<AtomicTaggedMutableRawPointer> { return storage+1 }
  private var pool: UnsafeMutablePointer<AtomicTaggedMutableRawPointer> { return storage+2 }

  public init()
  {
    let node = Node.dummy
    let tmrp = TaggedMutableRawPointer(node.storage, tag: 1)
    CAtomicsInitialize(head, tmrp)
    CAtomicsInitialize(tail, tmrp)
    CAtomicsInitialize(pool, tmrp)
  }

  deinit
  {
    // empty the queue
    // delete from tail to head because the `prev` pointer is most reliable
    let head = Node(storage: CAtomicsLoad(self.head, .acquire).ptr)
    var last = Node(storage: CAtomicsLoad(self.tail, .acquire).ptr)
    while last != head
    {
      let prev = Node(storage: last.prev.ptr)
      if let pointer = CAtomicsExchange(last.data, nil, .acquire)?.assumingMemoryBound(to: T.self)
      {
        pointer.deinitialize(count: 1)
        pointer.deallocate()
      }
      last.deallocate()
      last = prev
    }
    CAtomicsStore(head.next,  TaggedOptionalMutableRawPointer(nil, tag: 0), .release)

    var next = CAtomicsLoad(self.pool, .acquire).ptr as Optional
    while let node = Node(storage: next)
    {
      next = CAtomicsLoad(node.next, .acquire).ptr
      node.deallocate()
    }
    storage.deallocate()
  }

  public var isEmpty: Bool { return CAtomicsLoad(head, .relaxed).ptr == CAtomicsLoad(tail, .relaxed).ptr }

  public var count: Int {
    var i = 0
    // count from the current tail to the current head
    var current = CAtomicsLoad(self.tail, .acquire).ptr
    let head =    CAtomicsLoad(self.head, .acquire).ptr
    while current != head
    { // Iterate along the linked nodes while counting
      current = Node(storage: current).prev.ptr
      i += 1
    }
    return i
  }

  private func node(with element: T) -> Node
  {
    let reference = Unmanaged.passRetained(element).toOpaque()

    var pool = CAtomicsLoad(self.pool, .acquire)
    while pool.ptr != CAtomicsLoad(head, .acquire).ptr
    {
      let node = Node(storage: pool.ptr)
      if let n = CAtomicsLoad(node.next, .acquire).ptr
      {
        let next = pool.incremented(with: n)
        if CAtomicsCompareAndExchange(self.pool, &pool, next, .strong, .acqrel, .acquire)
        {
          node.initialize(to: reference)
          return node
        }
      }
      else
      { // this can happen if another thread has succeeded
        // in advancing the pool pointer and has already
        // started initializing the node for enqueueing
        pool = CAtomicsLoad(self.pool, .acquire)
      }
    }

    return Node(initializedWith: reference)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    var oldTail = CAtomicsLoad(tail, .acquire)
    var newTail: TaggedMutableRawPointer
    repeat {
      node.prev = oldTail.incremented()
      newTail =   oldTail.incremented(with: node.storage)
    } while !CAtomicsCompareAndExchange(tail, &oldTail, newTail, .weak, .release, .relaxed)

    // success, update the old tail's next link
    let lastNext = TaggedOptionalMutableRawPointer(node.storage, tag: oldTail.tag)
    CAtomicsStore(Node(storage: oldTail.ptr).next, lastNext, .release)
  }

  public func dequeue() -> T?
  {
    while true
    {
      let head = CAtomicsLoad(self.head, .acquire)
      let tail = CAtomicsLoad(self.tail, .acquire)
      let next = CAtomicsLoad(Node(storage: head.ptr).next, .acquire)

      if head == CAtomicsLoad(self.head, .acquire)
      {
        if head != tail
        { // queue is not empty
          if next.tag != head.tag
          { // an enqueue missed its final linking operation
            fixlist(tail: tail, head: head)
            continue
          }
          if let node = Node(storage: next.ptr),
             let element = CAtomicsLoad(node.data, .acquire)
          {
            let newhead = head.incremented(with: node.storage)
            if CAtomicsCompareAndExchange(self.head, head, newhead, .weak, .release)
            {
              return Unmanaged<T>.fromOpaque(element).takeRetainedValue()
            }
          }
        }
        return nil
      }
    }
  }

  private func fixlist(tail oldtail: TaggedMutableRawPointer, head oldhead: TaggedMutableRawPointer)
  {
    var current = oldtail
    while oldhead == CAtomicsLoad(self.head, .relaxed) && current != oldhead
    {
      let currentNode  = Node(storage: current.ptr)
      let previousNode = Node(storage: currentNode.prev.ptr)

      let tag = current.tag &- 1
      let updated = TaggedOptionalMutableRawPointer(current.ptr, tag: tag)
      CAtomicsStore(previousNode.next, updated, .relaxed)
      current = TaggedMutableRawPointer(previousNode.storage, tag: tag)
    }
  }
}
