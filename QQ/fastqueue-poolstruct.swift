//
//  queue.swift
//  concurrency
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin

/**
  A simple queue, implemented as a linked list.
*/

public struct FastQueue<T>: QueueType, SequenceType, GeneratorType
{
  private let qdata = UnsafeMutablePointer<LinkNodeQueueData>.alloc(1)
  private let pool =  AtomicStackInit()

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    qdata.initialize(LinkNodeQueueData())

    deallocator = QueueDeallocator(data: qdata, pool: pool)
  }

  public init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  public var isEmpty: Bool {
    return qdata.memory.head == nil
  }

  public var count: Int {
    return (qdata.memory.head == nil) ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var node = qdata.memory.head
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    var node = UnsafeMutablePointer<LinkNode>(OSAtomicDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<LinkNode>.alloc(1)
      node.memory.elem = COpaquePointer(UnsafeMutablePointer<T>.alloc(1))
    }
    node.memory.next = nil
    UnsafeMutablePointer<T>(node.memory.elem).initialize(newElement)

    OSSpinLockLock(&qdata.memory.lock)

    if qdata.memory.head == nil
    {
      qdata.memory.head = node
      qdata.memory.tail = node
      OSSpinLockUnlock(&qdata.memory.lock)
      return
    }

    qdata.memory.tail.memory.next = node
    qdata.memory.tail = node

    OSSpinLockUnlock(&qdata.memory.lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&qdata.memory.lock)

    if qdata.memory.head != nil
    {
      let node = qdata.memory.head

      // Promote the 2nd item to 1st
      qdata.memory.head = node.memory.next

      // Logical housekeeping
      if qdata.memory.head == nil { qdata.memory.tail = nil }

      OSSpinLockUnlock(&qdata.memory.lock)

      let element = UnsafeMutablePointer<T>(node.memory.elem).move()
      OSAtomicEnqueue(pool, node, 0)
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&qdata.memory.lock)
    return nil
  }

  public func next() -> T?
  {
    return dequeue()
  }

  public func generate() -> FastQueue
  {
    return self
  }
}

final private class QueueDeallocator<T>
{
  private let qdata: UnsafeMutablePointer<LinkNodeQueueData>
  private let pool:  StackHead

  init(data: UnsafeMutablePointer<LinkNodeQueueData>, pool: StackHead)
  {
    self.qdata = data
    self.pool = pool
  }

  deinit
  {
    // empty the queue
    while qdata.memory.head != nil
    {
      let node = qdata.memory.head
      qdata.memory.head = node.memory.next
      UnsafeMutablePointer<T>(node.memory.elem).destroy()
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
    }
    // release the queue head structure
    qdata.destroy()
    qdata.dealloc(1)

    // drain the pool
    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      let node = UnsafeMutablePointer<LinkNode>(OSAtomicDequeue(pool, 0))
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
    }
    // release the pool stack structure
    AtomicStackRelease(pool)
  }
}
