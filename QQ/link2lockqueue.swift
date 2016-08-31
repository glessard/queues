//
//  link2lockqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

/// Double-lock queue
///
/// Note that if `T` is a type that involves a reference -- i.e. either is an `AnyObject` or
/// directly references one internally, the queue will hold a live copy of the reference
/// past the moment it gets dequeued, until the successful `dequeue()` operation that follows it.
/// If that behaviour is undesirable, use another queue type.
///
/// Two-lock queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html

final public class Link2LockQueue<T>: QueueType, Sequence, IteratorProtocol
{
  private var head: UnsafeMutablePointer<Node<T>>? = nil
  private var tail: UnsafeMutablePointer<Node<T>> = UnsafeMutablePointer(bitPattern: 0x0000000f)!

  private var hlock = OS_SPINLOCK_INIT
  private var tlock = OS_SPINLOCK_INIT

  public init() { }

  deinit
  {
    // empty the queue
    while let node = head
    {
      head = node.pointee.next
      node.deinitialize()
      node.deallocate(capacity: 1)
    }
  }

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    var i = 0
    var node = head?.pointee.next
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.pointee.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = UnsafeMutablePointer<Node<T>>.allocate(capacity: 1)
    node.initialize(to: Node(newElement))

    OSSpinLockLock(&tlock)
    if head == nil
    { // This is the initial element
      tail = node
      let node = UnsafeMutablePointer<Node<T>>.allocate(capacity: 1)
      node.initialize(to: Node(newElement))
      node.pointee.next = tail
      head = node
    }
    else
    {
      tail.pointee.next = node
      tail = node
    }
    OSSpinLockUnlock(&tlock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&hlock)
    if let oldhead = head,
       let next = oldhead.pointee.next
    {
      head = next
      let element = next.pointee.elem
      OSSpinLockUnlock(&hlock)

      oldhead.deinitialize()
      oldhead.deallocate(capacity: 1)
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&hlock)
    return nil
  }
}

private struct Node<T>
{
  var next: UnsafeMutablePointer<Node<T>>? = nil
  let elem: T

  init(_ element: T)
  {
    elem = element
  }
}
