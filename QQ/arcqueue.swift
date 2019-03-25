//
//  arcqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import struct Darwin.os.lock.os_unfair_lock_s
import func   Darwin.os.lock.os_unfair_lock_lock
import func   Darwin.os.lock.os_unfair_lock_unlock

/// An ARC-based queue with a spin-lock for thread safety.

final public class ARCQueue<T>: QueueType
{
  public typealias Element = T

  private var head: Node<T>? = nil
  private var tail: Node<T>! = nil

  private var lock = os_unfair_lock_s()

  public init() { }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    var i = 0
    let tail = self.tail
    var node = head
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.next
      i += 1
      if current === tail { break }
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = Node(newElement)

    os_unfair_lock_lock(&lock)
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
    os_unfair_lock_unlock(&lock)
  }

  public func dequeue() -> T?
  {
    os_unfair_lock_lock(&lock)
    if let node = head
    {
      // Promote the 2nd node to 1st
      head = node.next
      node.next = nil

      // Logical housekeeping
      if head == nil { tail = nil }

      os_unfair_lock_unlock(&lock)
      return node.elem
    }

    // queue is empty
    os_unfair_lock_unlock(&lock)
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
