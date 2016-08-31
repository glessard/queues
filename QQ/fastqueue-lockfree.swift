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
  private var head = TaggedPointer<Node<T>>()
  private var tail = TaggedPointer<Node<T>>()

  private let pool = AtomicStackInit()

  public init()
  {
    let node = UnsafeMutablePointer<Node<T>>.allocate(capacity: 1)
    let elem = UnsafeMutablePointer<T>.allocate(capacity: 1)
    node.pointee = Node(elem)
    head = TaggedPointer(node, tag: 0)
    tail = TaggedPointer(node, tag: 0)
  }

  deinit
  {
    // empty the queue
    while let node = head.pointer
    {
      head = node.pointee.next
      if let elem = node.pointee.next.pointee?.elem
      {
        elem.deinitialize()
      }
      node.pointee.elem.deallocate(capacity: 1)
      node.deallocate(capacity: 1)
    }

    // drain the pool
    while UnsafePointer<OpaquePointer?>(pool).pointee != nil,
      let node = OSAtomicDequeue(pool, 0)?.assumingMemoryBound(to: Node<T>.self)
    {
      node.pointee.elem.deallocate(capacity: 1)
      node.deallocate(capacity: 1)
    }
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool { return head.pointer == tail.pointer }

  public var count: Int {
    var node = head
    var i = 0
    while let raw = node.pointer
    { // Iterate along the linked nodes while counting
      node = raw.pointee.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    var node: UnsafeMutablePointer<Node<T>>
    if let raw = OSAtomicDequeue(pool, 0)
    {
      node = raw.assumingMemoryBound(to: Node<T>.self)
    }
    else
    {
      node = UnsafeMutablePointer<Node<T>>.allocate(capacity: 1)
      node.pointee.elem = UnsafeMutablePointer<T>.allocate(capacity: 1)
    }
    node.pointee.next = TaggedPointer()
    node.pointee.elem.initialize(to: newElement)

    while true
    {
      let oldtail = tail
      if let oldpntr = oldtail.pointer
      {
        let oldnext = oldpntr.pointee.next

        if oldtail == tail
        { // was tail pointing to the last node?
          if oldnext.pointer == nil
          { // try to link the new node to the end of the list
            if oldpntr.pointee.next.CAS(old: oldnext, new: node)
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
  }

  public func dequeue() -> T?
  {
    while true
    {
      let oldhead = head
      let oldtail = tail

      if let oldpntr = oldhead.pointer
      {
        let newhead = oldpntr.pointee.next

        if oldhead == head
        {
          let newpntr = UnsafePointer<Node<T>>(newhead.pointer)

          if oldpntr != UnsafeMutablePointer<Node<T>>(oldtail.pointer)
          { // no need to deal with tail
            // read element before CAS, otherwise another dequeue racing ahead might free the node too early.
            let element = newpntr!.pointee.elem.pointee
            if head.CAS(old: oldhead, new: newpntr)
            {
              oldpntr.pointee.elem.deinitialize()
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
}

private struct Node<T>
{
  var sptr: Int64 = 0
  var next = TaggedPointer<Node<T>>()
  var elem: UnsafeMutablePointer<T>

  init(_ p: UnsafeMutablePointer<T>)
  {
    elem = p
  }
}
