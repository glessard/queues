//
//  fastosqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

final public class FastOSQueue<T>: QueueType
{
  private let head = AtomicQueueInit()
  private let pool = AtomicStackInit()

  public init() { }

  deinit
  {
    // empty the queue
    while UnsafePointer<COpaquePointer>(head).memory != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(OSAtomicFifoDequeue(head, 0))
      node.destroy()
      node.dealloc(1)
    }
    // release the queue head structure
    AtomicQueueRelease(head)

    // drain the pool
    while UnsafePointer<COpaquePointer>(pool).memory != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(OSAtomicDequeue(pool, 0))
      node.dealloc(1)
    }
    // release the pool stack structure
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool {
    return UnsafePointer<COpaquePointer>(head).memory == nil
  }

  public var count: Int {
    if UnsafePointer<COpaquePointer>(head).memory == nil { return 0 }

    // Not thread safe.

    var i = 0
    var node = UnsafePointer<UnsafeMutablePointer<Node<T>>>(head).memory
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

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> T?
  {
    let node = UnsafeMutablePointer<Node<T>>(OSAtomicFifoDequeue(head, 0))
    if node != nil
    {
      let element = node.memory.elem
      node.destroy()
      OSAtomicEnqueue(pool, node, 0)
      return element
    }

    // The queue is empty
    return nil
  }
}

private struct Node<T>
{
  var next: UnsafeMutablePointer<Node<T>> = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }
}
