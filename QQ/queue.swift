//
//  queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

/// An ARC-based queue with a spin-lock for thread safety.
///
/// Should be thread-safe in principle, but causes an ARC crash under heavy contention.
/// (rdar://20984816)

final public class Queue<T>: QueueType
{
  private var head: Node<T>? = nil
  private var tail: Node<T>! = nil

  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    var i = 0
    var node = head
    while let n = node
    { // Iterate along the linked nodes while counting
      node = n.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = Node(newElement)

    OSSpinLockLock(&lock)
    if head == nil
    {
      head = node
      tail = node
    }
    else
    {
      tail.next = node
      tail = node
    }
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)
    if let node = head
    {
      // Promote the 2nd node to 1st
      head = node.next

      // Logical housekeeping
      if head == nil { tail = nil }

      OSSpinLockUnlock(&lock)
      return node.elem
    }

    // queue is empty
    OSSpinLockUnlock(&lock)
    return nil
  }
}

/**
  A simple Node for the Queue implemented above.
  Clearly an implementation detail.
*/

private class Node<T>
{
  var next: Node? = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }
}
