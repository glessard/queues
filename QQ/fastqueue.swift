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

final public class FastQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: UnsafeMutablePointer<LinkNode> = nil
  private var tail: UnsafeMutablePointer<LinkNode> = nil

  private var size = 0

  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    while size > 0
    {
      dequeue()
    }
  }

  final public var isEmpty: Bool { return size == 0 }

  final public var count: Int { return size }

  public func CountNodes() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var nptr = head
    while nptr != nil
    { // Iterate along the linked nodes while counting
      nptr = nptr.memory.next
      i++
    }
    assert(i == size, "Queue might have lost data")

    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<LinkNode>.alloc(1)
    node.memory.next = nil
    let eptr = UnsafeMutablePointer<T>.alloc(1)
    eptr.initialize(newElement)
    node.memory.elem = COpaquePointer(eptr)

    OSSpinLockLock(&lock)

    if size <= 0
    {
      head = node
      tail = node
      size = 1
      OSSpinLockUnlock(&lock)
      return
    }

    tail.memory.next = node
    tail = node
    size += 1
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)

    if size > 0
    {
      let oldhead = head

      // Promote the 2nd item to 1st
      head = UnsafeMutablePointer<LinkNode>(head.memory.next)
      size -= 1

      // Logical housekeeping
      if size <= 0 { tail = UnsafeMutablePointer.null() }

      OSSpinLockUnlock(&lock)

      let eptr = UnsafeMutablePointer<T>(oldhead.memory.elem)
      let element = eptr.move()

      eptr.dealloc(1)
      oldhead.dealloc(1)

      return element
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
