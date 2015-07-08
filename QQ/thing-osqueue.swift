//
//  Thing-osqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

final public class ThingOSQueue: QueueType
{
  private let head = AtomicQueueInit()
  private let pool = AtomicStackInit()

  public init() { }

  deinit
  {
    // first, empty the queue
    while UnsafePointer<COpaquePointer>(head).memory != nil
    {
      let node = UnsafeMutablePointer<Node>(OSAtomicFifoDequeue(head, 0))
      node.destroy()
      node.dealloc(1)
    }
    // release the queue head structure
    AtomicQueueRelease(head)

    // drain the pool
    while UnsafePointer<COpaquePointer>(pool).memory != nil
    {
      UnsafeMutablePointer<Node>(OSAtomicDequeue(pool, 0)).dealloc(1)
    }
    // finally release the pool queue
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool {
    return UnsafeMutablePointer<COpaquePointer>(head).memory == nil
  }

  public var count: Int {
    // Not thread safe.
    var i = 0
    var node = UnsafePointer<UnsafeMutablePointer<Node>>(head).memory
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }
    return i
  }
  
  public func enqueue(newElement: Thing)
  {
    var node = UnsafeMutablePointer<Node>(OSAtomicDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<Node>.alloc(1)
    }
    node.initialize(Node(newElement))

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> Thing?
  {
    let node = UnsafeMutablePointer<Node>(OSAtomicFifoDequeue(head, 0))

    if node != nil
    {
      let element = node.memory.elem
      node.destroy()
      OSAtomicEnqueue(pool, node, 0)
      return element
    }
    return nil
  }
}

private struct Node
{
  var next: UnsafeMutablePointer<Node> = nil
  let elem: Thing

  init(_ s: Thing)
  {
    elem = s
  }
}
