//
//  linkqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin

final public class LinkQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: UnsafeMutablePointer<LinkNode> = nil
  private var tail: UnsafeMutablePointer<LinkNode>  = nil

  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    var h = UnsafeMutablePointer<LinkNode>(head)
    while h != nil
    {
      let node = h
      h = node.memory.next
      UnsafeMutablePointer<T>(node.memory.elem).destroy()
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
    }
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    return (head == nil) ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // Not thread safe.

    var i = 0
    var node = UnsafeMutablePointer<LinkNode>(head)
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<LinkNode>.alloc(1)
    let elem = UnsafeMutablePointer<T>.alloc(1)
    elem.initialize(newElement)
    node.memory = LinkNode(elem)

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
      let node = head

      // Promote the 2nd item to 1st
      head = node.memory.next

      // Logical housekeeping
      if head == nil { tail = nil }

      OSSpinLockUnlock(&lock)

      let element = UnsafeMutablePointer<T>(node.memory.elem).move()
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
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
