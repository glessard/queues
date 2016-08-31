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
  private var head: UnsafeMutablePointer<Node<T>>? = nil
  private var tail: UnsafeMutablePointer<Node<T>> = UnsafeMutablePointer(bitPattern: 0x0000000f)!

  private var hlock = OS_SPINLOCK_INIT
  private var tlock = OS_SPINLOCK_INIT

  private let pool = AtomicStack<Node<T>>()

  public init() { }

  deinit
  {
    // empty the queue
    while let node = head
    {
      node.pointee.next?.pointee.elem.deinitialize()
      head = node.pointee.next
      node.pointee.elem.deallocate(capacity: 1)
      node.deallocate(capacity: 1)
    }

    // drain the pool
    while let node = pool.pop()
    {
      node.pointee.elem.deallocate(capacity: 1)
      node.deallocate(capacity: 1)
    }
    // release the pool stack structure
    pool.release()
  }

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    var i = 0
    var node = head?.pointee.next
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.pointee.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node: UnsafeMutablePointer<Node<T>>
    if let popped = pool.pop()
    {
      node = popped
    }
    else
    {
      node = UnsafeMutablePointer.allocate(capacity: 1)
      node.pointee = Node()
    }
    node.pointee.next = nil
    node.pointee.elem.initialize(to: newElement)

    OSSpinLockLock(&tlock)
    if head == nil
    { // This is the initial element
      tail = node
      let node = UnsafeMutablePointer<Node<T>>.allocate(capacity: 1)
      node.pointee = Node()
      node.pointee.next = tail
      head = node
    }
    else
    {
      tail.pointee.next = node
      tail = node
    }
    OSSpinLockUnlock(&tlock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&hlock)
    if let oldhead = head,
       let next = oldhead.pointee.next
    {
      head = next
      let element = next.pointee.elem.move()
      OSSpinLockUnlock(&hlock)

      pool.push(oldhead)
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&hlock)
    return nil
  }
}

private struct Node<T>
{
  var next: UnsafeMutablePointer<Node<T>>? = nil
  let elem: UnsafeMutablePointer<T>

  init()
  {
    elem = UnsafeMutablePointer.allocate(capacity: 1)
  }
}
