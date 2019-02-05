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
    while true
    {
      let node = Node(storage: head.load(.relaxed).ptr)
      defer { node.deallocate() }

      let next = node.next.pointee.load(.relaxed)
      if let node = Node(storage: next.ptr)
      {
        node.deinitialize()
        let next = TaggedMutableRawPointer(node.storage, tag: next.tag)
        head.store(next, .relaxed)
      }
      else { break }
    }
  }

  public var isEmpty: Bool { return head.load(.relaxed).ptr == tail.load(.relaxed).ptr }

  public var count: Int {
    let tail = self.tail.load(.relaxed)
    let head = self.head.load(.relaxed)
    if head == tail { return 0 }

    // make sure the `next` pointers are in order
    fixlist(tail: tail, head: head)

    var i = 0
    var next = Node(storage: head.ptr).next.pointee.load(.relaxed).ptr
    while let current = Node(storage: next)
    { // Iterate along the linked nodes while counting
      next = current.next.pointee.load(.relaxed).ptr
      i += 1
      if current.storage == tail.ptr { break }
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = pool.pop() ?? LockFreeNode<T>()
    node.initialize(to: newElement)

    while true
    {
      let tail = self.tail.load(.acquire)
      let prev = TaggedOptionalMutableRawPointer(tail.ptr, tag: tail.tag &+ 1)
      node.prev.pointee.store(prev, .release)
      let next = TaggedMutableRawPointer(node.storage, tag: tail.tag &+ 1)
      if self.tail.CAS(tail, next, .weak, .release)
      { // success, update the old tail's next link
        let next = TaggedOptionalMutableRawPointer(node.storage, tag: tail.tag)
        Node(storage: tail.ptr).next.pointee.store(next, .release)
        break
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let head = self.head.load(.acquire)
      let tail = self.tail.load(.relaxed)
      let next = Node(storage: head.ptr).next.pointee.load(.acquire)

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
      let currentNode = Node(storage: current.ptr)
      if let currentPrev = Node(storage: currentNode.prev.pointee.load(.relaxed).ptr)
      {
        let tag = current.tag &- 1
        currentPrev.next.pointee.store(TaggedOptionalMutableRawPointer(current.ptr, tag: tag), .relaxed)
        current = TaggedMutableRawPointer(currentPrev.storage, tag: tag)
      }
    }
  }
}
