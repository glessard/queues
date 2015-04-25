//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

final public class FastQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: UnsafeMutablePointer<Node<T>> = nil
  private var tail: UnsafeMutablePointer<Node<T>> = nil

  private let pool = AtomicStackInit()
  private var lock = OS_SPINLOCK_INIT

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    // empty the queue
    while head != nil
    {
      let node = head
      head = node.memory.next
      node.destroy()
      node.dealloc(1)
    }

    // drain the pool
    while UnsafePointer<COpaquePointer>(pool).memory != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(OSAtomicDequeue(pool, 0))
      node.dealloc(1)
    }
    // release the pool stack structure
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    return (head == nil) ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // Not thread safe.

    var i = 0
    var node = head
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    var node = UnsafeMutablePointer<Node<T>>(OSAtomicDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<Node<T>>.alloc(1)
    }
    node.initialize(Node(newElement))

    OSSpinLockLock(&lock)
    if head == nil
    {
      head = node
      tail = node
    }
    else
    {
      tail.memory.next = node
      tail = node
    }
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)
    if head != nil
    { // Promote the 2nd item to 1st
      let node = head
      head = head.memory.next
      OSSpinLockUnlock(&lock)

      let element = node.memory.elem
      node.destroy()
      OSAtomicEnqueue(pool, node, 0)
      return element
    }
    else
    {
      OSSpinLockUnlock(&lock)
      return nil
    }
  }

  public func next() -> T?
  {
    return dequeue()
  }

  public func generate() -> Self
  {
    return self
  }
}

private struct Node<T>
{
  var nptr: COpaquePointer = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }

  var next: UnsafeMutablePointer<Node<T>> {
    get { return UnsafeMutablePointer<Node<T>>(nptr) }
    set { nptr = COpaquePointer(newValue) }
  }
}
