//
//  refqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin

public final class RefQueuePool<T: AnyObject>: QueueType
{
  private let head = AtomicQueueInit()
  private let pool = AtomicQueueInit()

  public init() { }

  convenience public init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    // first, empty the queue
    while UnsafeMutablePointer<COpaquePointer>(head).memory != nil
    {
      let node = UnsafeMutablePointer<ObjLinkNode>(OSAtomicFifoDequeue(head, 0))
      node.destroy()
      node.dealloc(1)
    }
    // release the queue head structure
    AtomicQueueRelease(head)

    // drain the pool
    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      UnsafeMutablePointer<ObjLinkNode>(OSAtomicFifoDequeue(pool, 0)).dealloc(1)
    }
    // finally release the pool queue
    AtomicQueueRelease(pool)
  }

  public var isEmpty: Bool {
    return UnsafeMutablePointer<COpaquePointer>(head).memory == nil
  }

  public var count: Int {
    return (UnsafeMutablePointer<COpaquePointer>(head).memory == nil) ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var nptr = UnsafeMutablePointer<UnsafeMutablePointer<ObjLinkNode>>(head).memory
    while nptr != nil
    { // Iterate along the linked nodes while counting
      nptr = nptr.memory.next
      i++
    }

    return i
  }
  
  public func enqueue(newElement: T)
  {
    var node = UnsafeMutablePointer<ObjLinkNode>(OSAtomicFifoDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<ObjLinkNode>.alloc(1)
    }
    node.initialize(ObjLinkNode(newElement))

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> T?
  {
    let node = UnsafeMutablePointer<ObjLinkNode>(OSAtomicFifoDequeue(head, 0))
    if node != nil
    {
      let element = node.memory.elem as? T
      node.destroy()
      node.memory.next = nil
      OSAtomicFifoEnqueue(pool, node, 0)
      return element
    }

    return nil
  }
}
