//
//  pointerqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

public struct PointerQueue4<T>: QueueType, SequenceType, GeneratorType
{
  private let head = AtomicQueueInit()
  private let pool = AtomicQueueInit()

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    deallocator = QueueDeallocator(head: head, pool: pool)
  }

  public init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  public var isEmpty: Bool {
    return UnsafeMutablePointer<Int>(head).memory == 0
  }

  public var count: Int {
    return (UnsafeMutablePointer<Int>(head).memory == 0) ? 0: CountNodes()
  }

  public func CountNodes() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var nptr = UnsafeMutablePointer<LinkNode>(head)
    while nptr != UnsafeMutablePointer.null()
    { // Iterate along the linked nodes while counting
      nptr = nptr.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    var node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(pool, 0))
    if node != nil
    {
      node.memory.next = nil
      UnsafeMutablePointer<T>(node.memory.elem).initialize(newElement)
    }
    else
    {
      node = UnsafeMutablePointer<LinkNode>.alloc(1)
      node.memory.next = nil
      let eptr = UnsafeMutablePointer<T>.alloc(1)
      eptr.initialize(newElement)
      node.initialize(LinkNode(next: nil, elem: COpaquePointer(eptr)))
    }

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> T?
  {
    let node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(head, 0))
    if node != nil
    {
      let element = UnsafeMutablePointer<T>(node.memory.elem).move()
      node.memory.next = nil
      OSAtomicFifoEnqueue(pool, node, 0)
      return element
    }
    else
    {
      return nil
    }
  }

  public func next() -> T?
  {
    return dequeue()
  }

  public func generate() -> PointerQueue4<T>
  {
    return self
  }
}

final private class QueueDeallocator<T>
{
  private let head: COpaquePointer
  private let pool: COpaquePointer

  init(head: COpaquePointer, pool: COpaquePointer)
  {
    self.head = head
    self.pool = pool
  }

  deinit
  {
    // first, empty the queue
    while UnsafeMutablePointer<Int>(head).memory != 0
    {
      let node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(head, 0))
      let item = UnsafeMutablePointer<T>(node.memory.elem)
      item.destroy()
      item.dealloc(1)
      node.destroy()
      node.dealloc(1)
    }
    // release the queue head structure
    AtomicQueueRelease(head)

    // Then, drain the pool
    while UnsafeMutablePointer<Int>(pool).memory != 0
    {
      let node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(pool, 0))
      let item = UnsafeMutablePointer<T>(node.memory.elem)
      item.dealloc(1)
      node.destroy()
      node.dealloc(1)
    }
    // release the pool queue structure
    AtomicQueueRelease(pool)
  }
}
