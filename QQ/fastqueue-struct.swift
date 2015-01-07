//
//  queue.swift
//  concurrency
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation

/**
  A simple queue, implemented as a linked list.
*/

public struct FastQueueStruct<T>: QueueType, SequenceType, GeneratorType
{
  private var head = UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>.alloc(1)
  private var tail = UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>.alloc(1)

  private var lock = UnsafeMutablePointer<Int32>.alloc(1)

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    head.initialize(nil)
    tail.initialize(nil)

    lock.initialize(OS_SPINLOCK_INIT)

    deallocator = QueueDeallocator(head: head, tail: tail, lock: lock)
  }

  public init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  public var isEmpty: Bool {
    return head.memory == nil
  }

  public var count: Int {
    return (head.memory == nil) ? 0 : CountNodes()
  }

  public func CountNodes() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var nptr = head.memory
    while nptr != nil
    { // Iterate along the linked nodes while counting
      nptr = nptr.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<LinkNode>.alloc(1)
    node.memory.next = nil
    let eptr = UnsafeMutablePointer<T>.alloc(1)
    eptr.initialize(newElement)
    node.memory.elem = COpaquePointer(eptr)

    OSSpinLockLock(lock)

    if head.memory == nil
    {
      head.memory = node
      tail.memory = node
      OSSpinLockUnlock(lock)
      return
    }

    tail.memory.memory.next = node
    tail.memory = node

    OSSpinLockUnlock(lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(lock)

    if head.memory != nil
    {
      let oldhead = head.memory

      // Promote the 2nd item to 1st
      head.memory = oldhead.memory.next

      // Logical housekeeping
      if head.memory == nil { tail.memory = nil }

      OSSpinLockUnlock(lock)

      let element = UnsafeMutablePointer<T>(oldhead.memory.elem).move()

      UnsafeMutablePointer<T>(oldhead.memory.elem).dealloc(1)
      oldhead.dealloc(1)

      return element
    }

    // queue is empty
    OSSpinLockUnlock(lock)
    return nil
  }

  // Implementation of GeneratorType

  public func next() -> T?
  {
    return dequeue()
  }

  // Implementation of SequenceType

  public func generate() -> FastQueueStruct
  {
    return self
  }
}

final private class QueueDeallocator<T>
{
  private let head: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>
  private let tail: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>

  private let lock: UnsafeMutablePointer<Int32>

  init(head: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>,
       tail: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>,
       lock: UnsafeMutablePointer<Int32>)
  {
    self.head = head
    self.tail = tail
    self.lock = lock
  }

  deinit
  {
    // empty the queue
    var node = head.memory
    while node != nil
    {
      let next = node.memory.next
      let eptr = UnsafeMutablePointer<T>(node.memory.elem)
      eptr.destroy()
      eptr.dealloc(1)
      node.dealloc(1)
      node = next
    }
    // release the queue head structure
    head.destroy()
    head.dealloc(1)
    tail.destroy()
    tail.dealloc(1)

    lock.destroy()
    lock.dealloc(1)
  }
}
