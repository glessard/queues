//
//  link2lockqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import let  Darwin.libkern.OSAtomic.OS_SPINLOCK_INIT
import func Darwin.libkern.OSAtomic.OSSpinLockLock
import func Darwin.libkern.OSAtomic.OSSpinLockUnlock

/// Double-lock queue
///
/// Note that if `T` is a type that involves a reference -- i.e. either is an `AnyObject` or
/// directly references one internally, the queue will hold a live copy of the reference
/// past the moment it gets dequeued, until the successful `dequeue()` operation that follows it.
/// If that behaviour is undesirable, use another queue type.
///
/// Two-lock queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html

final public class Link2LockQueue<T>: QueueType, Sequence, IteratorProtocol
{
  public typealias Element = T
  typealias Node = QueueNode<T>

  private var head: Node
  private var tail: Node

  private var hlock = OS_SPINLOCK_INIT
  private var tlock = OS_SPINLOCK_INIT

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

      oldhead.deallocate()
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&hlock)
    return nil
  }
}
