//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin

final public class FastQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: UnsafeMutablePointer<Node<T>> = nil
  private var tail: UnsafeMutablePointer<Node<T>>  = nil

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
      head = UnsafeMutablePointer<Node<T>>(node.memory.next)
      UnsafeMutablePointer<T>(node.memory.elem).destroy()
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
    }

    // drain the pool
    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(OSAtomicDequeue(pool, 0))
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
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
      node = UnsafeMutablePointer<Node<T>>(node.memory.next)
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
      node.memory = Node(UnsafeMutablePointer<T>.alloc(1))
    }
    node.memory.next = nil
    node.memory.elem.initialize(newElement)

    OSSpinLockLock(&lock)

    if head == nil
    {
      head = node
      tail = node
      OSSpinLockUnlock(&lock)
      return
    }

    tail.memory.next = COpaquePointer(node)
    tail = node
    OSSpinLockUnlock(&lock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&lock)

    if head != nil
    {
      let node = head

      // Promote the 2nd item to 1st
      head = UnsafeMutablePointer<Node<T>>(node.memory.next)

      // Logical housekeeping
      if head == nil { tail = nil }

      OSSpinLockUnlock(&lock)

      let element = node.memory.elem.move()
      OSAtomicEnqueue(pool, node, 0)
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&lock)
    return nil
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
  var next: COpaquePointer = nil
  var p: COpaquePointer

  init(_ p: UnsafeMutablePointer<T>)
  {
    self.p = COpaquePointer(p)
  }

  var elem: UnsafeMutablePointer<T> {
    get { return UnsafeMutablePointer<T>(p) }
  }
}
