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
  private var head = UnsafeMutablePointer<UnsafeMutablePointer<PointerNode>>.alloc(1)
  private var tail = UnsafeMutablePointer<UnsafeMutablePointer<PointerNode>>.alloc(1)

  private var size = UnsafeMutablePointer<Int>.alloc(1)
  private var lock = UnsafeMutablePointer<Int32>.alloc(1)

  private let pool = AtomicStackInit()

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    head.initialize(UnsafeMutablePointer.null())
    tail.initialize(UnsafeMutablePointer.null())

    size.initialize(0)
    lock.initialize(OS_SPINLOCK_INIT)

    deallocator = QueueDeallocator(head: head, tail: tail, size: size, lock: lock, pool: pool)
  }

  public init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  public var isEmpty: Bool { return size.memory == 0 }

  public var count: Int { return size.memory }

  public func CountNodes() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var nptr = head.memory
    while nptr != UnsafeMutablePointer.null()
    { // Iterate along the linked nodes while counting
      nptr = UnsafeMutablePointer<PointerNode>(nptr.memory.next)
      i++
    }
    assert(i == size.memory, "Queue might have lost data")

    return i
  }

  public func enqueue(newElement: T)
  {
    var node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
    if node != UnsafeMutablePointer.null()
    {
      node.memory.next = UnsafeMutablePointer.null()
      UnsafeMutablePointer<T>(node.memory.elem).initialize(newElement)
    }
    else
    {
      node = UnsafeMutablePointer<PointerNode>.alloc(1)
      node.memory.next = UnsafeMutablePointer.null()
      let eptr = UnsafeMutablePointer<T>.alloc(1)
      eptr.initialize(newElement)
      node.memory.elem = UnsafeMutablePointer<Void>(eptr)
    }

    OSSpinLockLock(lock)
    if size.memory <= 0
    {
      head.memory = node
      tail.memory = node
      size.memory = 1
      OSSpinLockUnlock(lock)
      return
    }

    tail.memory.memory.next = node
    tail.memory = node
    size.memory += 1
    OSSpinLockUnlock(lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(lock)

    if size.memory > 0
    {
      let oldhead = head.memory

      // Promote the 2nd item to 1st
      head.memory = oldhead.memory.next
      size.memory -= 1

      // Logical housekeeping
      if size.memory <= 0 { tail.memory = UnsafeMutablePointer.null() }

      OSSpinLockUnlock(lock)

      let element = UnsafeMutablePointer<T>(oldhead.memory.elem).move()
//      oldhead.memory.next = UnsafeMutablePointer.null()
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
  private let head: UnsafeMutablePointer<UnsafeMutablePointer<PointerNode>>
  private let tail: UnsafeMutablePointer<UnsafeMutablePointer<PointerNode>>

  private let size: UnsafeMutablePointer<Int>
  private let lock: UnsafeMutablePointer<Int32>

  private let pool: COpaquePointer

  init(head: UnsafeMutablePointer<UnsafeMutablePointer<PointerNode>>,
       tail: UnsafeMutablePointer<UnsafeMutablePointer<PointerNode>>,
       size: UnsafeMutablePointer<Int>,
       lock: UnsafeMutablePointer<Int32>,
       pool: COpaquePointer)
  {
    self.head = head
    self.tail = tail
    self.size = size
    self.lock = lock
    self.pool = pool
  }

  deinit
  {
    // empty the queue
    var node = head.memory
    while node != UnsafeMutablePointer.null()
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

    // drain the pool
    node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
    while node != UnsafeMutablePointer.null()
    {
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
      node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
    }
    AtomicStackRelease(pool)

    size.destroy()
    size.dealloc(1)
    lock.destroy()
    lock.dealloc(1)
  }
}
