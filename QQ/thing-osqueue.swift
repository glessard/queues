//
//  Thing-osqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Dispatch

final public class ThingOSQueue: QueueType
{
  private let head = AtomicQueueInit()
  private let pool = AtomicStackInit()

  public init() { }

  convenience public init(_ newElement: Thing)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    // first, empty the queue
    while UnsafeMutablePointer<COpaquePointer>(head).memory != nil
    {
      let node = UnsafeMutablePointer<ThingNode>(OSAtomicFifoDequeue(head, 0))
      node.destroy()
      node.dealloc(1)
    }
    // release the queue head structure
    AtomicQueueRelease(head)

    // drain the pool
    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      UnsafeMutablePointer<ThingNode>(OSAtomicDequeue(pool, 0)).dealloc(1)
    }
    // finally release the pool queue
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool {
    return UnsafeMutablePointer<COpaquePointer>(head).memory == nil
  }

  public var count: Int {
    return (UnsafeMutablePointer<COpaquePointer>(head).memory == nil) ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // Not thread safe.

    var i = 0
    var node = UnsafeMutablePointer<UnsafeMutablePointer<ThingNode>>(head).memory
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }

    return i
  }
  
  public func enqueue(newElement: Thing)
  {
    var node = UnsafeMutablePointer<ThingNode>(OSAtomicDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<ThingNode>.alloc(1)
    }
    node.initialize(ThingNode(newElement))

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> Thing?
  {
    let node = UnsafeMutablePointer<ThingNode>(OSAtomicFifoDequeue(head, 0))
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

private struct ThingNode
{
  var next: UnsafeMutablePointer<ThingNode> = nil
  var elem: Thing

  init(_ s: Thing)
  {
    elem = s
  }
}
