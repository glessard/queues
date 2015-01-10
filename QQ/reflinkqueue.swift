//
//  queue.swift
//  concurrency
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin

final public class RefLinkQueue<T: AnyObject>: QueueType, SequenceType, GeneratorType
{
  private var head: COpaquePointer = nil
  private var tail: COpaquePointer = nil

  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    var h = UnsafeMutablePointer<ObjLinkNode>(head)
    while h != nil
    {
      let node = h
      h = node.memory.next
      node.destroy()
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
    var node = UnsafeMutablePointer<ObjLinkNode>(head)
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<ObjLinkNode>.alloc(1)
    node.initialize(ObjLinkNode(newElement))

    OSSpinLockLock(&lock)

    if head == nil
    {
      head = COpaquePointer(node)
      tail = COpaquePointer(node)
      OSSpinLockUnlock(&lock)
      return
    }

    UnsafeMutablePointer<ObjLinkNode>(tail).memory.next = node
    tail = COpaquePointer(node)
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)

    if head != nil
    {
      let node = UnsafeMutablePointer<ObjLinkNode>(head)

      // Promote the 2nd item to 1st
      head = COpaquePointer(node.memory.next)

      // Logical housekeeping
      if head == nil { tail = nil }

      OSSpinLockUnlock(&lock)

      let element = node.memory.elem as? T
      node.destroy()
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
