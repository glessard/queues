//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import func Darwin.libkern.OSAtomic.OSAtomicEnqueue
import func Darwin.libkern.OSAtomic.OSAtomicDequeue

/// Lock-free queue with node recycling
///
/// Note that this algorithm is not designed for tri-state memory as used in Swift.
/// This means that it does not work correctly in multi-threaded situations (as in, accesses memory in an incorrect state.)
/// It was an interesting experiment.
///
/// Lock-free queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html

final public class LockFreeFastQueue<T>: QueueType
{
  private var head = Int64()
  private var tail = Int64()

  private let pool = AtomicStackInit()

  public init()
  {
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.memory = Node(nil)
    head = TaggedPointer(node, tag: 0)
    tail = TaggedPointer(node, tag: 0)
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

    // drain the pool
    while UnsafePointer<COpaquePointer>(pool).memory != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(OSAtomicDequeue(pool, 0))
      node.memory.elem.dealloc(1)
      node.dealloc(1)
    }
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool { return head.pointer == tail.pointer }

  public var count: Int {
    var i = 0
    var node = UnsafeMutablePointer<Node<T>>(head.pointer).memory.next
    while node.pointer != nil
    { // Iterate along the linked nodes while counting
      node = UnsafeMutablePointer<Node<T>>(node.pointer).memory.next
      i++
    }
    return i
  }

  public func enqueue(newElement: T)
  {
    var node = UnsafeMutablePointer<Node<T>>(OSAtomicDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<Node<T>>.alloc(1)
      node.memory.elem = UnsafeMutablePointer<T>.alloc(1)
    }
    node.memory.next = 0
    node.memory.elem.initialize(newElement)

    while true
    {
      let oldtail = tail
      let oldpntr = UnsafeMutablePointer<Node<T>>(oldtail.pointer)
      let oldnext = oldpntr.memory.next

      if oldtail == tail
      { // was tail pointing to the last node?
        if oldnext.pointer == nil
        { // try to link the new node to the end of the list
          if oldpntr.memory.next.CAS(old: oldnext, new: node)
          { // success. try to have tail point to the inserted node.
            tail.CAS(old: oldtail, new: node)
            break
          }
        }
        else
        { // tail wasn't pointing to the actual last node; try to fix it.
          tail.CAS(old: oldtail, new: oldnext.pointer)
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

      let oldpntr = UnsafeMutablePointer<Node<T>>(oldhead.pointer)
      let newhead = oldpntr.memory.next

      if oldhead == head
      {
        let newpntr = UnsafePointer<Node<T>>(newhead.pointer)

        if oldpntr != UnsafeMutablePointer<Node<T>>(oldtail.pointer)
        { // no need to deal with tail
          // read element before CAS, otherwise another dequeue racing ahead might free the node too early.
          let element = newpntr.memory.elem.memory
          if head.CAS(old: oldhead, new: newpntr)
          {
            if oldpntr.memory.elem == nil
            {
              oldpntr.memory = Node(UnsafeMutablePointer<T>.alloc(1))
            }
            else
            {
              oldpntr.memory.elem.destroy()
            }
            OSAtomicEnqueue(pool, oldpntr, 0)
            return element
          }
        }
        else
        {
          if newpntr == nil
          { // queue is empty
            return nil
          }
          // tail wasn't pointing to the actual last node; try to fix it.
          tail.CAS(old: oldtail, new: newpntr)
        }
      }
    }
  }
}

private struct Node<T>
{
  let sptr: Int64 = 0
  var next: Int64 = 0
  var elem: UnsafeMutablePointer<T>

  init(_ p: UnsafeMutablePointer<T>)
  {
    elem = p
  }
}
