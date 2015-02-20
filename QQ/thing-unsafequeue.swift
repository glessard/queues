//
//  Thing-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Dispatch

final public class ThingUnsafeQueue: QueueType
{
  private var head: UnsafeMutablePointer<Node> = nil
  private var tail: UnsafeMutablePointer<Node> = nil

  private let pool = AtomicStackInit()

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

    // drain the pool
    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      UnsafeMutablePointer<Node>(OSAtomicDequeue(pool, 0)).dealloc(1)
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

    if head == nil
    {
      head = node
      tail = node
      return
    }

    tail.memory.next = node
    tail = node
  }

  public func dequeue() -> Thing?
  {
    if head != nil
    {
      let node = head

      // Promote the 2nd item to 1st
      head = node.memory.next

      // Logical housekeeping
      if head == nil { tail = nil }

      let element = node.memory.elem
      node.destroy()
      OSAtomicEnqueue(pool, node, 0)
      return element
    }

    // queue is empty
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
