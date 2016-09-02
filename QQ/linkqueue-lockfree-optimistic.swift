//
//  fastqueue.swift
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
  private var head = TaggedPointer<Node<T>>()
  private var tail = TaggedPointer<Node<T>>()

  public init()
  {
    let node = UnsafeMutablePointer<Node<T>>.allocate(capacity: 1)
    let elem = UnsafeMutablePointer<T>.allocate(capacity: 1)
    node.pointee = Node(elem)
    head = TaggedPointer(node, tag: 1)
    tail = TaggedPointer(node, tag: 1)
  }

  deinit
  {
    // empty the queue
    while let node = head.pointer
    {
      head = node.pointee.next
      node.pointee.elem.deinitialize()
      node.pointee.elem.deallocate(capacity: 1)
      node.deallocate(capacity: 1)
    }
  }

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    if head == tail { return 0 }

    // make sure the `next` pointers are in order
    fixlist(tail: tail, head: head)

    var i = 0
    var node = head.pointee?.next
    while let raw = node?.pointer
    { // Iterate along the linked nodes while counting
      node = raw.pointee.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = UnsafeMutablePointer<Node<T>>.allocate(capacity: 1)
    let elem = UnsafeMutablePointer<T>.allocate(capacity: 1)
    elem.initialize(to: newElement)
    node.pointee = Node(elem)

    while true
    {
      let oldtail = tail
      if let oldpntr = oldtail.pointer
      {
        let oldtag  = oldtail.tag

        node.pointee.prev = TaggedPointer(oldpntr, tag: oldtag+1)
        if tail.CAS(old: oldtail, new: node)
        {
          oldpntr.pointee.next = TaggedPointer(node, tag: oldtag)
          break
        }
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let oldhead = head
      let oldtail = tail

      if let oldpntr = oldhead.pointer, oldhead == head
      {
        let newhead = oldpntr.pointee.next
        if oldhead != oldtail
        {
          if newhead.isEmpty || newhead.tag != oldhead.tag
          {
            fixlist(tail: oldtail, head: oldhead)
          }
          else
          {
            let newpntr = newhead.pointer
            // read element before CAS, otherwise another dequeue racing ahead might free the node too early.
            let element = newpntr!.pointee.elem.pointee
            if head.CAS(old: oldhead, new: newpntr)
            {
              oldpntr.pointee.elem.deinitialize()
              oldpntr.pointee.elem.deallocate(capacity: 1)
              oldpntr.deallocate(capacity: 1)
              return element
            }
          }
        }
        else
        {
          return nil
        }
      }
    }
  }

  private func fixlist(tail oldtail: TaggedPointer<Node<T>>, head oldhead: TaggedPointer<Node<T>>)
  {
    var current = oldtail
    while oldhead == head && current != oldhead
    {
      if let prevptr = current.pointee?.prev.pointer
      {
        prevptr.pointee.next = TaggedPointer(current.pointer, tag: current.tag-1)
        current = TaggedPointer(prevptr, tag: current.tag-1)
      }
    }
  }
}

private struct Node<T>
{
  var next = TaggedPointer<Node<T>>()
  var prev = TaggedPointer<Node<T>>()
  var elem: UnsafeMutablePointer<T>

  init(_ p: UnsafeMutablePointer<T>)
  {
    elem = p
  }
}
