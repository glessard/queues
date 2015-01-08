//
//  queue.swift
//  concurrency
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation

/**
  A simple queue, implemented as a linked list.
*/

final public class SimpleQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: Node? = nil
  private var tail: Node! = nil

  private var size: Int = 0

  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  final public var isEmpty: Bool { return size == 0 }

  final public var count: Int { return size }

  public func CountNodes() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var node = head
    while let n = node
    { // Iterate along the linked nodes while counting
      node = n.next
      i++
    }
    assert(i == size, "Queue might have lost data")

    return Int(i)
  }

  public func enqueue(newElement: T)
  {
    let newNode = Node(newElement)

    OSSpinLockLock(&lock)
    if size <= 0
    {
      head = newNode
      tail = newNode
      size = 1
      OSSpinLockUnlock(&lock)
      return
    }

    tail.next = newNode
    tail = newNode
    size += 1
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)
    if size > 0
    {
      let oldhead = head!

      // Promote the 2nd node to 1st
      head = oldhead.next

      size -= 1

      // Logical housekeeping
      if size <= 0 { tail = nil }

      OSSpinLockUnlock(&lock)
      return oldhead.elem as? T
    }

    // queue is empty
    OSSpinLockUnlock(&lock)
    return nil
  }

  // Implementation of GeneratorType

  public func next() -> T?
  {
    return dequeue()
  }

  // Implementation of SequenceType

  public func generate() -> Self
  {
    return self
  }
}

/**
  A simple Node for the Queue implemented above.
  Clearly an implementation detail.
*/

private class Node
{
  var next: Node? = nil
  let elem: Any

  init(_ e: Any)
  {
    elem = e
  }
}
