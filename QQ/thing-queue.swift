//
//  Thing-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

final public class ThingQueue: QueueType
{
  private var head: UnsafeMutablePointer<Node> = nil
  private var tail: UnsafeMutablePointer<Node> = nil

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
    while head != nil
    {
      let node = head
      head = node.memory.next
      node.destroy()
      node.dealloc(1)
    }

    while UnsafePointer<COpaquePointer>(pool).memory != nil
    {
      UnsafeMutablePointer<Node>(OSAtomicDequeue(pool, 0)).dealloc(1)
    }
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    // Not thread safe.
    var i = 0
    var node = UnsafeMutablePointer<Node>(head)
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }
    return i
  }

  public func enqueue(newElement: Thing)
  {
    var node = UnsafeMutablePointer<Node>(OSAtomicDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<Node>.alloc(1)
    }
    node.initialize(Node(newElement))

    OSSpinLockLock(&lock)
    if head == nil
    {
      head = node
      tail = node
    }
    else
    {
      tail.memory.next = node
      tail = node
    }
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> Thing?
  {
    OSSpinLockLock(&lock)
    let node = head
    if node != nil
    { // Promote the 2nd item to 1st
      head = node.memory.next
    }
    OSSpinLockUnlock(&lock)

    if node != nil
    {
      let element = node.memory.elem
      node.destroy()
      OSAtomicEnqueue(pool, node, 0)
      return element
    }
    return nil
  }
}

private struct Node
{
  var next: UnsafeMutablePointer<Node> = nil
  let elem: Thing

  init(_ s: Thing)
  {
    elem = s
  }
}
