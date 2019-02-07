//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import CAtomics

/// Lock-free queue with node recycling
///
/// Note that this algorithm is not designed for tri-state memory as used in Swift.
/// This means that it does not work correctly in multi-threaded situations (as in, accesses memory in an incorrect state.)
/// It was an interesting experiment.
///
/// Lock-free queue algorithm adapted from Edya Ladan-Mozes and Nir Shavit,
/// "An optimistic approach to lock-free FIFO queues",
/// Distributed Computing (2008) 20:323-341; DOI 10.1007/s00446-007-0050-0
///
/// See also:
/// Proceedings of the 18th International Conference on Distributed Computing (DISC) 2004
/// http://people.csail.mit.edu/edya/publications/OptimisticFIFOQueue-DISC2004.pdf

final public class OptimisticFastQueue<T>: QueueType
{
  public typealias Element = T
  typealias Node = LockFreeNode<T>

  private var head = AtomicTaggedMutableRawPointer()
  private var tail = AtomicTaggedMutableRawPointer()

  private let pool = AtomicStack<LockFreeNode<T>>()

  public init()
  {
    let node = Node.dummy
    let tmrp = TaggedMutableRawPointer(node.storage, tag: 1)
    head.initialize(tmrp)
    tail.initialize(tmrp)
  }

  deinit
  {
    // empty the queue
    // delete from tail to head because the `prev` pointer is most reliable
    let head = Node(storage: self.head.load(.acquire).ptr)
    var last = Node(storage: self.tail.load(.acquire).ptr)
    while last != head
    {
      let prev = Node(storage: last.prev.ptr)
      last.deinitialize()
      last.deallocate()
      last = prev
    }
    head.deallocate()
  }

  public var isEmpty: Bool { return head.load(.relaxed).ptr == tail.load(.relaxed).ptr }

  public var count: Int {
    var i = 0
    // count from the current tail to the current head
    var current = self.tail.load(.acquire)
    let head =    self.head.load(.acquire)
    while current.ptr != head.ptr
    { // Iterate along the linked nodes while counting
      current = Node(storage: current.ptr).prev
      i += 1
    }
    return i
  }

  private func node(with element: T) -> Node
  {
    if let reused = pool.pop()
    {
      reused.initialize(to: element)
      return reused
    }
    return Node(initializedWith: element)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    var oldTail = self.tail.load(.acquire)
    var newTail: TaggedMutableRawPointer
    repeat {
      node.prev = oldTail.incremented()
      newTail =   oldTail.incremented(with: node.storage)
    } while !self.tail.loadCAS(&oldTail, newTail, .weak, .release, .relaxed)

    // success, update the old tail's next link
    let lastNext = TaggedOptionalMutableRawPointer(node.storage, tag: oldTail.tag)
    Node(storage: oldTail.ptr).next.store(lastNext, .relaxed)
  }

  public func dequeue() -> T?
  {
    while true
    {
      let head = self.head.load(.acquire)
      let tail = self.tail.load(.acquire)
      let next = Node(storage: head.ptr).next.load(.acquire)

      if head == self.head.load(.acquire)
      {
        if head != tail
        { // queue is not empty
          if next.tag != head.tag
          { // an enqueue missed its final linking operation
            fixlist(tail: tail, head: head)
            continue
          }
          if let node = Node(storage: next.ptr),
             let element = node.read() // must happen before deinitialize in another thread
          {
            let newhead = TaggedMutableRawPointer(node.storage, tag: head.tag &+ 1)
            if self.head.CAS(head, newhead, .weak, .release)
            {
              node.deinitialize()
              pool.push(Node(storage: head.ptr))
              return element
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
    while oldhead == self.head.load(.relaxed) && current != oldhead
    {
      let currentNode  = Node(storage: current.ptr)
      let previousNode = Node(storage: currentNode.prev.ptr)

      let tag = current.tag &- 1
      let updated = TaggedOptionalMutableRawPointer(current.ptr, tag: tag)
      previousNode.next.store(updated, .relaxed)
      current = TaggedMutableRawPointer(previousNode.storage, tag: tag)
    }
  }
}
