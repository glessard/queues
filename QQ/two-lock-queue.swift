//
//  two-lock-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import struct Darwin.os.lock.os_unfair_lock_s
import func   Darwin.os.lock.os_unfair_lock_lock
import func   Darwin.os.lock.os_unfair_lock_unlock

/// Double-lock queue
///
/// Two-lock queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html

final public class TwoLockQueue<T>: QueueType, Sequence, IteratorProtocol
{
  public typealias Element = T
  typealias Node = QueueNode<T>

  private var head: Node
  private var tail: Node

  private var hlock = os_unfair_lock_s()
  private var tlock = os_unfair_lock_s()

  public init()
  {
    tail = Node.dummy
    head = tail
  }

  deinit
  {
    // empty the queue
    var next = head.next
    while let node = next
    {
      next = node.next
      node.deinitialize()
      node.deallocate()
    }
    head.deallocate()
  }

  public var isEmpty: Bool { return head.storage == tail.storage }

  public var count: Int {
    var i = 0
    let tail = self.tail
    var node = head.next
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

    os_unfair_lock_lock(&tlock)
    tail.next = node
    tail = node
    os_unfair_lock_unlock(&tlock)
  }

  public func dequeue() -> T?
  {
    os_unfair_lock_lock(&hlock)
    let oldhead = head
    if let next = head.next
    {
      head = next
      let element = next.move()
      os_unfair_lock_unlock(&hlock)

      oldhead.deallocate()
      return element
    }

    // queue is empty
    os_unfair_lock_unlock(&hlock)
    return nil
  }
}
