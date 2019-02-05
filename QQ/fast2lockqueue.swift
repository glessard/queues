//
//  fast2lockqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import let  Darwin.libkern.OSAtomic.OS_SPINLOCK_INIT
import func Darwin.libkern.OSAtomic.OSSpinLockLock
import func Darwin.libkern.OSAtomic.OSSpinLockUnlock

/// Double-lock queue with node recycling
///
/// Two-lock queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html

final public class Fast2LockQueue<T>: QueueType
{
  public typealias Element = T

  private var head: QueueNode<T>
  private var tail: QueueNode<T>

  private var hlock = OS_SPINLOCK_INIT
  private var tlock = OS_SPINLOCK_INIT

  private let pool = AtomicStack<QueueNode<T>>()

  public init()
  {
    tail = QueueNode.dummy
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
    let node = pool.pop() ?? QueueNode()
    node.initialize(to: newElement)

    OSSpinLockLock(&tlock)
    tail.next = node
    tail = node
    OSSpinLockUnlock(&tlock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&hlock)
    let oldhead = head
    if let next = head.next
    {
      head = next
      let element = next.move()
      OSSpinLockUnlock(&hlock)

      pool.push(oldhead)
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&hlock)
    return nil
  }
}
