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
  private var head = TaggedPointer<LockFreeNode<T>>()
  private var tail = TaggedPointer<LockFreeNode<T>>()

  public init()
  {
    let node = LockFreeNode<T>()
    head = TaggedPointer(node, tag: 1)
    tail = TaggedPointer(node, tag: 1)
  }

  deinit
  {
    // empty the queue
    while let node = head.pointee
    {
      node.next.pointee.pointee?.deinitialize()
      head = node.next.pointee
      node.deallocate()
    }
  }

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    if head == tail { return 0 }

    // make sure the `next` pointers are in order
    fixlist(tail: tail, head: head)

    var i = 0
    var node = head.pointee?.next
    while let current = node?.pointee
    { // Iterate along the linked nodes while counting
      node = current.pointee?.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = LockFreeNode(initializedWith: newElement)
    node.next.pointee = TaggedPointer()

    while true
    {
      let tail = self.tail
      if let tailNode = tail.pointee
      {
        let tag  = tail.tag
        node.prev.pointee = TaggedPointer(tailNode, tag: tag+1)
        if self.tail.CAS(old: tail, new: node)
        {
          let next = TaggedPointer(node, tag: tag)
          tailNode.next.pointee = next
          break
        }
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let head = self.head
      let tail = self.tail

      if let firstNext = head.pointee?.next.pointee,
         head == self.head
      {
        if head != tail
        {
          if firstNext.tag != head.tag
          {
            fixlist(tail: tail, head: head)
            continue
          }
          if let element = firstNext.pointee?.read()
          {
            if self.head.CAS(old: head, new: firstNext.pointee!)
            {
              firstNext.pointee?.deinitialize()
              let oldhead = head.pointee!
              oldhead.deallocate()
              return element
            }
          }
        }
        return nil
      }
    }
  }

  private func fixlist(tail oldtail: TaggedPointer<LockFreeNode<T>>, head oldhead: TaggedPointer<LockFreeNode<T>>)
  {
    var current = oldtail
    while oldhead == self.head && current != oldhead
    {
      if let curNode = current.pointee,
         let currentPrev = curNode.prev.pointee.pointee
      {
        currentPrev.next.pointee = TaggedPointer(curNode, tag: current.tag-1)
        current = TaggedPointer(currentPrev, tag: current.tag-1)
      }
    }
  }
}
