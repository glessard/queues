//
//  pointerqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

private let offset = PointerNodeLinkOffset()
private let length = PointerNodeSize()

public struct PointerQueue3<T>: QueueType, SequenceType, GeneratorType
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
    return UnsafeMutablePointer<COpaquePointer>(head).memory == nil
  }

  public var count: Int {
    return (UnsafeMutablePointer<COpaquePointer>(head).memory == nil) ? 0 : CountNodes()
  }

  public func CountNodes() -> Int
  {
    // For testing; don't call this under contention.

    var i = 0
    var nptr = UnsafeMutablePointer<UnsafeMutablePointer<PointerNode>>(head).memory
    while nptr != nil
    { // Iterate along the linked nodes while counting
      nptr = nptr.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    var node = UnsafeMutablePointer<PointerNode>(OSAtomicFifoDequeue(pool, offset))
    if node != nil
    {
      node.memory.next = nil
      UnsafeMutablePointer<T>(node.memory.elem).initialize(newElement)
    }
    else
    {
      node = UnsafeMutablePointer<PointerNode>.alloc(1)
      node.memory.next = nil
      let item = UnsafeMutablePointer<T>.alloc(1)
      item.initialize(newElement)
      node.memory.elem = UnsafeMutablePointer<Void>(item)
    }

    OSAtomicFifoEnqueue(head, node, offset)
  }

  public func dequeue() -> T?
  {
    let node = UnsafeMutablePointer<PointerNode>(OSAtomicFifoDequeue(head, offset))
    if node != nil
    {
      let element = UnsafeMutablePointer<T>(node.memory.elem).move()
      node.memory.next = nil
      OSAtomicFifoEnqueue(pool, node, offset)
      return element
    }

    return nil
  }

  public func next() -> T?
  {
    return dequeue()
  }

  public func generate() -> PointerQueue3<T>
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
    while UnsafeMutablePointer<COpaquePointer>(head).memory != nil
    {
      let node = UnsafeMutablePointer<PointerNode>(OSAtomicFifoDequeue(head, offset))
      let item = UnsafeMutablePointer<T>(node.memory.elem)
      item.destroy()
      item.dealloc(1)
      node.dealloc(1)
    }
    // release the queue head structure
    AtomicQueueRelease(head)

    // Then, drain the pool
    while UnsafeMutablePointer<COpaquePointer>(pool).memory != nil
    {
      let node = UnsafeMutablePointer<PointerNode>(OSAtomicFifoDequeue(pool, offset))
      UnsafeMutablePointer<T>(node.memory.elem).dealloc(1)
      node.dealloc(1)
    }
    // release the pool queue structure
    AtomicQueueRelease(pool)
  }
}
