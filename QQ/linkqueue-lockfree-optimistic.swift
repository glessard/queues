//
//  linkqueue-lockfree-optimistic.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import CAtomics

/// Lock-free queue
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

final public class OptimisticLinkQueue<T>: QueueType
{
  public typealias Element = T
  typealias Node = LockFreeNode<T>

  private var head = AtomicTaggedMutableRawPointer()
  private var tail = AtomicTaggedMutableRawPointer()

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
    let tail = self.tail.load(.relaxed)
    let head = self.head.load(.relaxed)
    if head == tail { return 0 }

    // make sure the `next` pointers are in order
    fixlist(tail: tail, head: head)

    var i = 0
    var next = Node(storage: head.ptr).next.load(.relaxed).ptr
    while let current = Node(storage: next)
    { // Iterate along the linked nodes while counting
      next = current.next.load(.relaxed).ptr
      i += 1
      if current.storage == tail.ptr { break }
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
            let newhead = head.incremented(with: node.storage)
            if self.head.CAS(head, newhead, .weak, .release)
            {
              node.deinitialize()
              Node(storage: head.ptr).deallocate()
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
      let currentPrev = Node(storage: currentNode.prev.ptr)

      let tag = current.tag &- 1
      let updated = TaggedOptionalMutableRawPointer(current.ptr, tag: tag)
      currentPrev.next.store(updated, .relaxed)
      current = TaggedMutableRawPointer(currentPrev.storage, tag: tag)
    }
  }
}
