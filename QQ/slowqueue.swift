//
//  slowqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin

final public class SlowQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: Node<T>? = nil
  private var tail: Node<T>! = nil

  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    return (head == nil) ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // Not thread safe.

    var i = 0
    var node = head
    while let n = node
    { // Iterate along the linked nodes while counting
      node = n.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    let newNode = Node(newElement)

    OSSpinLockLock(&lock)
    if head == nil
    {
      head = newNode
      tail = newNode
      OSSpinLockUnlock(&lock)
      return
    }

    tail.next = newNode
    tail = newNode
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)
    if let node = head
    {
      // Promote the 2nd node to 1st
      head = node.next

      // Logical housekeeping
      if head == nil { tail = nil }

      OSSpinLockUnlock(&lock)
      return node.elem
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

private class Node<T>
{
  var next: Node? = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }
}
