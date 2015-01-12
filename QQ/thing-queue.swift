//
//  Thing-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Dispatch

final public class ThingQueue: QueueType
{
  private var head: COpaquePointer = nil
  private var tail: COpaquePointer = nil

  private let pool = AtomicStackInit()
  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public convenience init(_ newElement: Thing)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    var h = UnsafeMutablePointer<ThingNode>(head)
    while h != nil
    {
      let node = h
      h = node.memory.next
      node.destroy()
      node.dealloc(1)
    }

    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      UnsafeMutablePointer<ThingNode>(OSAtomicDequeue(pool, 0)).dealloc(1)
    }
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    return (head == nil) ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // Not thread safe.

    var i = 0
    var node = UnsafeMutablePointer<ThingNode>(head)
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: Thing)
  {
    var node = UnsafeMutablePointer<ThingNode>(OSAtomicDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<ThingNode>.alloc(1)
    }
    node.initialize(ThingNode(newElement))

    OSSpinLockLock(&lock)

    if head == nil
    {
      head = COpaquePointer(node)
      tail = COpaquePointer(node)
      OSSpinLockUnlock(&lock)
      return
    }

    UnsafeMutablePointer<ThingNode>(tail).memory.next = node
    tail = COpaquePointer(node)
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> Thing?
  {
    OSSpinLockLock(&lock)

    if head != nil
    {
      let node = UnsafeMutablePointer<ThingNode>(head)

      // Promote the 2nd item to 1st
      head = COpaquePointer(node.memory.next)

      // Logical housekeeping
      if head == nil { tail = nil }

      OSSpinLockUnlock(&lock)

      let element = node.memory.elem
      node.destroy()
      OSAtomicEnqueue(pool, node, 0)
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&lock)
    return nil
  }
}


private struct ThingNode
{
  var next: UnsafeMutablePointer<ThingNode> = nil
  var elem: Thing

  init(_ s: Thing)
  {
    elem = s
  }
}
