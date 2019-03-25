//
//  recycling-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import struct Darwin.os.lock.os_unfair_lock_s
import func   Darwin.os.lock.os_unfair_lock_lock
import func   Darwin.os.lock.os_unfair_lock_unlock

final public class RecyclingQueue<T>: QueueType
{
  public typealias Element = T
  typealias Node = QueueNode<T>

  private var head: Node? = nil
  private var tail: Node! = nil

  private let pool = AtomicStack<Node>()
  private var lock = os_unfair_lock_s()

  public init() { }

  deinit
  {
    // empty the queue
    while let node = head
    {
      head = node.next
      node.deinitialize()
      node.deallocate()
    }
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    var i = 0
    let tail = self.tail
    var node = head
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.next
      i += 1
      if current == tail { break }
    }
    return i
  }

  private func node(with element: T) -> Node
  {
    if let reused = pool.pop()
    {
      reused.initialize(to: element)
      return reused
    }
    return Node(initializedWith: element)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    os_unfair_lock_lock(&lock)
    if head == nil
    {
      head = node
      tail = node
    }
    else
    {
      tail.next = node
      tail = node
    }
    os_unfair_lock_unlock(&lock)
  }

  public func dequeue() -> T?
  {
    os_unfair_lock_lock(&lock)
    if let node = head
    { // Promote the 2nd item to 1st
      head = node.next
      os_unfair_lock_unlock(&lock)

      let element = node.move()
      pool.push(node)
      return element
    }

    // queue is empty
    os_unfair_lock_unlock(&lock)
    return nil
  }
}
