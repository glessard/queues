//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import func Darwin.libkern.OSAtomic.OSAtomicEnqueue
import func Darwin.libkern.OSAtomic.OSAtomicDequeue

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
  private var head = Int64()
  private var tail = Int64()

  public init()
  {
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.memory = Node(nil)
    head = TaggedPointer(node, tag: 1)
    tail = TaggedPointer(node, tag: 1)
  }

  deinit
  {
    // empty the queue
    while head.pointer != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(head.pointer)
      head = node.memory.next
      if node.memory.elem != nil
      {
        node.memory.elem.destroy()
        node.memory.elem.dealloc(1)
      }
      node.dealloc(1)
    }
  }

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    if head == tail { return 0 }

    // make sure the `next` pointers are in order
    fixlist(tail: tail, head: head)

    var i = 0
    var nodepointer = UnsafePointer<Node<T>>(head.pointer).memory.next.pointer
    while nodepointer != nil
    { // Iterate along the linked nodes while counting
      nodepointer = UnsafePointer<Node<T>>(nodepointer).memory.next.pointer
      i++
    }
    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.memory = Node(UnsafeMutablePointer<T>.alloc(1))
    node.memory.elem.initialize(newElement)

    while true
    {
      let oldtail = tail
      let oldpntr = UnsafeMutablePointer<Node<T>>(oldtail.pointer)
      let oldtag  = oldtail.tag

      node.memory.prev = TaggedPointer(oldpntr, tag: oldtag+1)
      if tail.CAS(old: oldtail, new: node)
      {
        oldpntr.memory.next = TaggedPointer(node, tag: oldtag)
        break
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let oldhead = head
      let oldpntr = UnsafeMutablePointer<Node<T>>(oldhead.pointer)

      let oldtail = tail
      let newhead = oldpntr.memory.next

      if oldhead == head
      {
        if oldhead != oldtail
        {
          if newhead == 0 || newhead.tag != oldhead.tag
          {
            fixlist(tail: oldtail, head: oldhead)
          }
          else
          {
            let newpntr = UnsafeMutablePointer<Node<T>>(newhead.pointer)
            // read element before CAS, otherwise another dequeue racing ahead might free the node too early.
            let element = newpntr.memory.elem.memory
            if head.CAS(old: oldhead, new: newpntr)
            {
              let oldelem = oldpntr.memory.elem
              if oldelem != nil
              {
                oldelem.destroy()
                oldelem.dealloc(1)
              }
              oldpntr.dealloc(1)
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

  private func fixlist(tail oldtail: Int64, head oldhead: Int64)
  {
    var current = oldtail
    while oldhead == head && current != oldhead
    {
      let prevptr = UnsafeMutablePointer<Node<T>>(UnsafePointer<Node<T>>(current.pointer).memory.prev.pointer)
      prevptr.memory.next = TaggedPointer(current.pointer, tag: current.tag-1)
      current = TaggedPointer(prevptr, tag: current.tag-1)
    }
  }
}

private struct Node<T>
{
  var next: Int64 = 0
  var prev: Int64 = 0
  var elem: UnsafeMutablePointer<T>

  init(_ p: UnsafeMutablePointer<T>)
  {
    elem = p
  }
}
