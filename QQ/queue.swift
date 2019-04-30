//
//  queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import struct Darwin.os.lock.os_unfair_lock_s
import func   Darwin.os.lock.os_unfair_lock_lock
import func   Darwin.os.lock.os_unfair_lock_unlock

final public class Queue<T>: QueueType
{
  public typealias Element = T
  typealias Node = QueueNode<T>

  private var head: Node? = nil
  private var tail: Node! = nil

  private let lock = UnsafeMutablePointer<os_unfair_lock_s>.allocate(capacity: 1)

  public init() { lock.pointee = os_unfair_lock_s() }

  deinit
  {
    while let node = head
    {
      head = node.next
      node.deinitialize()
      node.deallocate()
    }
    lock.deallocate()
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

  public func enqueue(_ newElement: T)
  {
    let node = Node(initializedWith: newElement)

    os_unfair_lock_lock(lock)
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
    os_unfair_lock_unlock(lock)
  }

  public func dequeue() -> T?
  {
    os_unfair_lock_lock(lock)
    if let node = head
    { // Promote the 2nd item to 1st
      head = node.next
      os_unfair_lock_unlock(lock)

      let element = node.move()
      node.deallocate()
      return element
    }

    // queue is empty
    os_unfair_lock_unlock(lock)
    return nil
  }
}
