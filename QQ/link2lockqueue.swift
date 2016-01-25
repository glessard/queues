//
//  fastqueue.swift
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

final public class Link2LockQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: UnsafeMutablePointer<Node<T>> = nil
  private var tail: UnsafeMutablePointer<Node<T>> = nil

  private var hlock = OS_SPINLOCK_INIT
  private var tlock = OS_SPINLOCK_INIT

  public init() { }

  deinit
  {
    // empty the queue
    while head != nil
    {
      let node = head
      head = node.memory.next
      node.destroy()
      node.dealloc(1)
    }
  }

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    var i = 0
    var node = head.memory.next
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i += 1
    }
    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.initialize(Node(newElement))

    OSSpinLockLock(&tlock)
    if tail == nil
    { // This is the initial element
      tail = node
      let node = UnsafeMutablePointer<Node<T>>.alloc(1)
      node.initialize(Node(newElement))
      node.memory.next = tail
      head = node
    }
    else
    {
      tail.memory.next = node
      tail = node
    }
    OSSpinLockUnlock(&tlock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&hlock)
    if head == nil
    {
      OSSpinLockUnlock(&hlock)
      return nil
    }

    let next = head.memory.next
    if next != nil
    {
      let oldhead = head
      head = next
      let element = next.memory.elem
      OSSpinLockUnlock(&hlock)

      oldhead.destroy()
      oldhead.dealloc(1)
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&hlock)
    return nil
  }
}

private struct Node<T>
{
  var next: UnsafeMutablePointer<Node<T>> = nil
  let elem: T

  init(_ element: T)
  {
    elem = element
  }
}
