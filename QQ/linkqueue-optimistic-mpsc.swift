//
//  linkqueue-lockfree-optimistic.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import CAtomics

/// Multiple-Producer, Single-Consumer, (mostly) Lock-Free Queue
///
/// Adapted from the Optimistic Lock-free queue algorithm by Edya Ladan-Mozes and Nir Shavit,
/// "An optimistic approach to lock-free FIFO queues",
/// Distributed Computing (2008) 20:323-341; DOI 10.1007/s00446-007-0050-0
///
/// See also:
/// Proceedings of the 18th International Conference on Distributed Computing (DISC) 2004
/// http://people.csail.mit.edu/edya/publications/OptimisticFIFOQueue-DISC2004.pdf
///
/// This algorithm is lock-free for both the Producer and Consumer paths.
/// Calls to enqueue() can be made from multiple simultaneous threads (multiple producers.)
/// Calls to dequeue() must be serialized in some way (single consumer.)
/// The serialization of the consumer enables the algorithm to work properly with
/// ARC-enabled memory and avoids other memory-related issues by ensuring that
/// no concurrency exists on that path.

final public class OptimisticMPSCLinkQueue<T>: QueueType
{
  public typealias Element = T
  typealias Node = LockFreeNode<T>

  private var head: TaggedMutableRawPointer
  private var tail: AtomicTaggedMutableRawPointer

  public init()
  {
    let node = Node.dummy
    head = TaggedMutableRawPointer(node.storage, tag: 1)
    tail = AtomicTaggedMutableRawPointer(head)
  }

  deinit
  {
    // empty the queue
    // delete from tail to head because the `prev` pointer is most reliable
    let head = Node(storage: self.head.ptr)
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

  public var isEmpty: Bool { return head.ptr == tail.load(.relaxed).ptr }

  public var count: Int {
    var i = 0
    // count from the current tail until head
    var current = tail.load(.acquire)
    while current.ptr != head.ptr
    { // Iterate along the linked nodes while counting
      current = Node(storage: current.ptr).prev
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = LockFreeNode(initializedWith: newElement)

    var oldTail = self.tail.load(.acquire)
    var newTail: TaggedMutableRawPointer
    repeat {
      node.prev = oldTail.incremented()
      newTail =   oldTail.incremented(with: node.storage)
    } while !self.tail.loadCAS(&oldTail, newTail, .weak, .release, .relaxed)

    // success, update the old tail's next link
    let oldTailNext = TaggedOptionalMutableRawPointer(node.storage, tag: oldTail.tag)
    Node(storage: oldTail.ptr).next.store(oldTailNext, .relaxed)
  }

  public func dequeue() -> T?
  {
    while true
    {
      let head = self.head
      let tail = self.tail.load(.acquire)
      let next = Node(storage: head.ptr).next.load(.acquire)

      guard head != tail else { return nil }
      // queue is not empty
      if (next.tag != head.tag) || (next.tag == 0 && next.ptr == nil)
      { // an enqueue missed its final linking operation
        fixlist(tail: tail, head: head)
      }
      else if let node = Node(storage: next.ptr)
      {
        self.head = head.incremented(with: node.storage)
        Node(storage: head.ptr).deallocate()
        return node.move()
      }
    }
  }

  private func fixlist(tail oldtail: TaggedMutableRawPointer, head oldhead: TaggedMutableRawPointer)
  { // should only be called as part of the (serialized) dequeue() path
    var current = oldtail
    while current != oldhead
    {
      let currentNode = Node(storage: current.ptr)
      let currentPrev = Node(storage: currentNode.prev.ptr)

      let tag = current.tag &- 1
      let updated = TaggedOptionalMutableRawPointer(current.ptr, tag: tag)
      currentPrev.next.store(updated, .relaxed)
      current = TaggedMutableRawPointer(currentPrev.storage, tag: tag)
    }
  }
}
