//
//  refqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

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
      let node = UnsafeMutablePointer<RefLinkNode>(OSAtomicFifoDequeue(head, 0))
      node.memory.elem.release()
      node.dealloc(1)
    }
    // release the queue head structure
    AtomicQueueRelease(head)

    // drain the pool
    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      UnsafeMutablePointer<RefLinkNode>(OSAtomicFifoDequeue(pool, 0)).dealloc(1)
    }
    // finally release the pool queue
    AtomicQueueRelease(pool)
  }

  public var isEmpty: Bool {
    return UnsafeMutablePointer<COpaquePointer>(head).memory == nil
  }

  public var count: Int {
    return (UnsafeMutablePointer<COpaquePointer>(head).memory == nil) ? 0 : CountNodes()
  }

  public func CountNodes() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var nptr = UnsafeMutablePointer<UnsafeMutablePointer<RefLinkNode>>(head).memory
    while nptr != nil
    { // Iterate along the linked nodes while counting
      nptr = nptr.memory.next
      i++
    }

    return i
  }
  
  public func enqueue(item: T)
  {
    var node = UnsafeMutablePointer<RefLinkNode>(OSAtomicFifoDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<RefLinkNode>.alloc(1)
    }
    node.memory = RefLinkNode(next: nil, elem: Unmanaged.passRetained(item))

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> T?
  {
    let node = UnsafeMutablePointer<RefLinkNode>(OSAtomicFifoDequeue(head, 0))
    if node != nil
    {
      let element = node.memory.elem.takeRetainedValue() as? T
      node.memory.next = nil
      OSAtomicFifoEnqueue(pool, node, 0)
      return element
    }

    return nil
  }
}
