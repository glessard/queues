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

final public class AnyLinkQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: UnsafeMutablePointer<AnyLinkNode> = nil
  private var tail: UnsafeMutablePointer<AnyLinkNode> = nil

  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    while head != nil
    {
      let node = head
      head = node.memory.next
      node.destroy()
      node.dealloc(1)
    }
  }

  final public var isEmpty: Bool { return head == nil }

  final public var count: Int {
    return (head == nil) ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // This is really not thread-safe.

    var i = 0
    var node = head
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<AnyLinkNode>.alloc(1)
    node.initialize(AnyLinkNode(newElement))

    OSSpinLockLock(&lock)
    if head == nil
    {
      head = node
      tail = node
      OSSpinLockUnlock(&lock)
      return
    }

    tail.memory.next = node
    tail = node
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)

    if head != nil
    {
      let oldhead = head

      // Promote the 2nd item to 1st
      head = head.memory.next

      // Logical housekeeping
      if head == nil { tail = nil }

      OSSpinLockUnlock(&lock)

      let element = oldhead.memory.elem as? T

      oldhead.destroy()
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
