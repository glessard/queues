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

public struct FastQueueStruct<T>: QueueType
{
  private var head = UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>.alloc(1)
  private var tail = UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>.alloc(1)

  private var size = UnsafeMutablePointer<Int>.alloc(1)
  private var lock = UnsafeMutablePointer<Int32>.alloc(1)

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    head.initialize(UnsafeMutablePointer.null())
    tail.initialize(UnsafeMutablePointer.null())

    size.initialize(0)
    lock.initialize(OS_SPINLOCK_INIT)

    deallocator = QueueDeallocator(head: head, tail: tail, size: size, lock: lock)
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
      nptr = nptr.memory.next
      i++
    }
    assert(i == size.memory, "Queue might have lost data")

    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<LinkNode>.alloc(1)
    node.memory.next = UnsafeMutablePointer.null()
    let eptr = UnsafeMutablePointer<T>.alloc(1)
    eptr.initialize(newElement)
    node.memory.elem = COpaquePointer(eptr)

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

      let eptr = UnsafeMutablePointer<T>(oldhead.memory.elem)
      let element = eptr.move()

      eptr.dealloc(1)
      oldhead.dealloc(1)

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

  private let size: UnsafeMutablePointer<Int>
  private let lock: UnsafeMutablePointer<Int32>

  init(head: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>,
       tail: UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>,
       size: UnsafeMutablePointer<Int>,
       lock: UnsafeMutablePointer<Int32>)
  {
    self.head = head
    self.tail = tail
    self.size = size
    self.lock = lock
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

    size.destroy()
    size.dealloc(1)
    lock.destroy()
    lock.dealloc(1)
  }
}
