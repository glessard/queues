//
//  queue.swift
//  concurrency
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation

private let offset = PointerNodeLinkOffset()
private let length = PointerNodeSize()

/**
  A simple queue, implemented as a linked list.
*/

final public class FastPoolQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head = UnsafeMutablePointer<PointerNode>.null()
  private var tail = UnsafeMutablePointer<PointerNode>.null()

  private let pool = AtomicStackInit()

  private var size = 0

  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    while size > 0
    {
      dequeue()
    }

    var node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, offset))
    while node != UnsafeMutablePointer.null()
    {
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
      node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, offset))
    }

    AtomicStackRelease(pool)
  }

  final public var isEmpty: Bool { return size == 0 }

  final public var count: Int { return size }

  public func CountNodes() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var nptr = head
    while nptr != UnsafeMutablePointer.null()
    { // Iterate along the linked nodes while counting
      nptr = nptr.memory.next
      i++
    }
    assert(i == size, "Queue might have lost data")

    return i
  }

  public func enqueue(newElement: T)
  {
    var node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, offset))
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
      node.memory.elem = UnsafeMutablePointer(eptr)
    }

    OSSpinLockLock(&lock)

    if size <= 0
    {
      head = node
      tail = node
      size = 1
      OSSpinLockUnlock(&lock)
      return
    }

    tail.memory.next = node
    tail = node
    size += 1
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)

    if size > 0
    {
      let oldhead = head

      // Promote the 2nd item to 1st
      head = head.memory.next
      size -= 1

      // Logical housekeeping
      if size <= 0 { tail = UnsafeMutablePointer.null() }

      OSSpinLockUnlock(&lock)

      let element = UnsafeMutablePointer<T>(oldhead.memory.elem).move()
//      oldhead.memory.next = UnsafeMutablePointer.null()
      OSAtomicEnqueue(pool, oldhead, offset)

      return element
    }

    // queue is empty
    OSSpinLockUnlock(&lock)
    return nil
  }

  // Implementation of GeneratorType

  public func next() -> T?
  {
    return dequeue()
  }

  // Implementation of SequenceType

  public func generate() -> Self
  {
    return self
  }
}
