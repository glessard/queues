//
//  queue.swift
//  concurrency
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

/**
  A simple queue, implemented as a linked list.
*/

public struct FastPoolQueueStruct<T>: QueueType
{
  private var head = UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>.alloc(1)
  private var tail = UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>.alloc(1)

  private var lock = UnsafeMutablePointer<Int32>.alloc(1)

  private let pool = AtomicStackInit()

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    head.initialize(nil)
    tail.initialize(nil)

    lock.initialize(OS_SPINLOCK_INIT)

    deallocator = QueueDeallocator(head: head, tail: tail, lock: lock, pool: pool)
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
    var node = UnsafeMutablePointer<LinkNode>(OSAtomicDequeue(pool, 0))
    if node != nil
    {
      node.memory.next = nil
      UnsafeMutablePointer<T>(node.memory.elem).initialize(newElement)
    }
    else
    {
      node = UnsafeMutablePointer<LinkNode>.alloc(1)
      node.memory.next = nil
      let eptr = UnsafeMutablePointer<T>.alloc(1)
      eptr.initialize(newElement)
      node.memory.elem = COpaquePointer(eptr)
    }

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
//      oldhead.memory.next = nil
      OSAtomicEnqueue(pool, oldhead, 0)

      return element
    }

    // queue is empty
    OSSpinLockUnlock(lock)
    return nil
  }
}

final private class QueueDeallocator<T>
{
  private let head: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>
  private let tail: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>

  private let lock: UnsafeMutablePointer<Int32>

  private let pool: COpaquePointer

  init(head: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>,
       tail: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>,
       lock: UnsafeMutablePointer<Int32>,
       pool: COpaquePointer)
  {
    self.head = head
    self.tail = tail
    self.lock = lock
    self.pool = pool
  }

  deinit
  {
    // empty the queue
    while head.memory != nil
    {
      let node = head.memory
      head.memory = node.memory.next
      UnsafeMutablePointer<T>(node.memory.elem).destroy()
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
    }
    // release the queue head structure
    head.destroy()
    head.dealloc(1)
    tail.destroy()
    tail.dealloc(1)

    // drain the pool
    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      let node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
    }
    // release the pool stack structure
    AtomicStackRelease(pool)

    lock.destroy()
    lock.dealloc(1)
  }
}
