//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

final public class LockFreeFastQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: UnsafeMutablePointer<Node<T>> = nil
  private var tail: UnsafeMutablePointer<Node<T>> = nil

  private let pool = AtomicStackInit()

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
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
      UnsafeMutablePointer<Node<T>>(OSAtomicDequeue(pool, 0)).dealloc(1)
    }
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

    if head == nil && AtomicCompareAndSwapPointer(nil, node, &head)
    {
      tail = node
      OSMemoryBarrier()
    }
    else
    {
      while tail == nil
      { OSMemoryBarrier() }

      while AtomicCompareAndSwapPointer(nil, node, &tail.memory.next) == false
      { OSMemoryBarrier() }

      tail = node
      OSMemoryBarrier()
    }
  }

  public func dequeue() -> T?
  {
    while head != nil
    { // Promote the 2nd item to 1st
      let node = head
      if AtomicCompareAndSwapPointer(node, head.memory.next, &head)
      {
        // MUST SET TAIL TO nil IF APPROPRIATE, BUT RACE CONDITION.
        let element = node.memory.elem
        node.destroy()
        OSAtomicEnqueue(pool, node, 0)
        return element
      }
    }
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
  var nptr: UnsafeMutablePointer<Void> = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }

  var next: UnsafeMutablePointer<Node<T>> {
    get { return UnsafeMutablePointer<Node<T>>(nptr) }
    set { nptr = UnsafeMutablePointer<Void>(newValue) }
  }
}

private func AtomicCompareAndSwapPointer<T>(old: UnsafeMutablePointer<T>, new: UnsafeMutablePointer<T>,
                                            pointer: UnsafeMutablePointer<UnsafeMutablePointer<T>>) -> Bool
{
  return OSAtomicCompareAndSwapLongBarrier(unsafeBitCast(old, Int.self), unsafeBitCast(new, Int.self),
                                           UnsafeMutablePointer<Int>(pointer))
}
