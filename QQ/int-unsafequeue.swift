//
//  int-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin

final public class IntUnsafeQueue: QueueType
{
  private var head: UnsafeMutablePointer<Node> = nil
  private var tail: UnsafeMutablePointer<Node>  = nil

  private let pool = AtomicStackInit()

  public init() { }

  public convenience init(_ newElement: UInt64)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    // empty the queue
    while head != nil
    {
      let node = head
      head = node.memory.next
      node.dealloc(1)
    }

    // drain the pool
    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      UnsafeMutablePointer<Node>(OSAtomicDequeue(pool, 0)).dealloc(1)
    }
    // release the pool stack structure
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

  public func enqueue(newElement: UInt64)
  {
    var node = UnsafeMutablePointer<Node>(OSAtomicDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<Node>.alloc(1)
    }
    node.memory = Node(newElement)

    if head == nil
    {
      head = node
      tail = node
      return
    }

    tail.memory.next = node
    tail = node
  }

  public func dequeue() -> UInt64?
  {
    if head != nil
    {
      let node = head

      // Promote the 2nd item to 1st
      head = head.memory.next

      // Logical housekeeping
      if head == nil { tail = nil }

      let element = node.memory.elem
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
  let elem: UInt64

  init(_ i: UInt64)
  {
    elem = i
  }
}
