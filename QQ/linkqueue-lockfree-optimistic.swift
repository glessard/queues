//
//  linkqueue-lockfree-optimistic.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

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

  private var head = AtomicTP<LockFreeNode<T>>()
  private var tail = AtomicTP<LockFreeNode<T>>()

  public init()
  {
    let node = LockFreeNode<T>()
    head.store(TaggedPointer(node))
    tail.store(TaggedPointer(node))
  }

  deinit
  {
    // empty the queue
    while let node = head.load()?.node
    {
      defer { node.deallocate() }

      if let next = node.next.pointee.load()
      {
        next.node.deinitialize()
        head.store(next)
      }
      else { break }
    }
  }

  public var isEmpty: Bool { return head.load() == tail.load() }

  public var count: Int {
    if head.load() == tail.load() { return 0 }

    // make sure the `next` pointers are in order
    fixlist(tail: tail.load()!, head: head.load()!)

    var i = 0
    let current = head.load()!.node
    var pointer = current.next.pointee.load()
    while let current = pointer?.node
    { // Iterate along the linked nodes while counting
      pointer = current.next.pointee.load()
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = LockFreeNode(initializedWith: newElement)

    while true
    {
      let tail = self.tail.load()!
      let prev = TaggedPointer(tail.node, incrementingTag: tail)
      node.prev.pointee.store(prev)
      if self.tail.CAS(old: tail, new: node)
      { // success, update the old tail's next link
        let next = TaggedPointer(node, usingTag: tail)
        tail.node.next.pointee.store(next)
        break
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let head = self.head.load()!
      let tail = self.tail.load()!
      let next = head.node.next.pointee.load()

      if head == self.head.load()
      {
        if head != tail
        { // queue is not empty
          if next?.tag != head.tag
          { // an enqueue missed its final linking operation
            fixlist(tail: tail, head: head)
            continue
          }
          if let newhead = next?.node,
             let element = newhead.read(), // must happen before deinitialize in another thread
             self.head.CAS(old: head, new: newhead)
          {
            newhead.deinitialize()
            head.node.deallocate()
            return element
          }
        }
        return nil
      }
    }
  }

  private func fixlist(tail oldtail: TaggedPointer<LockFreeNode<T>>, head oldhead: TaggedPointer<LockFreeNode<T>>)
  {
    var current = oldtail
    while oldhead == self.head.load()! && current != oldhead
    {
      if let currentPrev = current.node.prev.pointee.load()?.node
      {
        let tag = current.tag &- 1
        currentPrev.next.pointee.store(TaggedPointer(current.node, tag: tag))
        current = TaggedPointer(currentPrev, tag: tag)
      }
    }
  }
}
