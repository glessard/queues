//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import let  Darwin.libkern.OSAtomic.OS_SPINLOCK_INIT
import func Darwin.libkern.OSAtomic.OSSpinLockLock
import func Darwin.libkern.OSAtomic.OSSpinLockUnlock

final public class FastQueue<T>: QueueType
{
  private var head: UnsafeMutablePointer<Node<T>>? = nil
  private var tail: UnsafeMutablePointer<Node<T>> = UnsafeMutablePointer(bitPattern: 0x0000000f)!

  private let pool = AtomicStack<Node<T>>()
  private var lock = OS_SPINLOCK_INIT

  public init() { }

  deinit
  {
    // empty the queue
    while let node = head
    {
      head = node.pointee.next
      node.deinitialize()
      node.deallocate(capacity: 1)
    }

    // drain the pool
    while let node = pool.pop()
    {
      node.deallocate(capacity: 1)
    }
    // release the pool stack structure
    pool.release()
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    var i = 0
    var node = head
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.pointee.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = pool.pop() ?? UnsafeMutablePointer.allocate(capacity: 1)
    node.initialize(to: Node(newElement))

    OSSpinLockLock(&lock)
    if head == nil
    {
      head = node
      tail = node
    }
    else
    {
      tail.pointee.next = node
      tail = node
    }
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)
    if let node = head
    { // Promote the 2nd item to 1st
      head = node.pointee.next
      OSSpinLockUnlock(&lock)

      let element = node.pointee.elem
      node.deinitialize()
      pool.push(node)
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&lock)
    return nil
  }
}

private struct Node<T>
{
  var next: UnsafeMutablePointer<Node<T>>? = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }
}
