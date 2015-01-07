//
//  pointerqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

public struct PointerQueue2<T>: QueueType, SequenceType, GeneratorType
{
  private let head = AtomicQueueInit()
  private let size = UnsafeMutablePointer<Int32>.alloc(1)

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    size.initialize(0)
    deallocator = QueueDeallocator(head: head, size: size)
  }

  public init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  public var isEmpty: Bool { return size.memory < 1 }

  public var count: Int { return Int(size.memory) }

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
    assert(i == Int(size.memory), "Queue might have lost data")

    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<LinkNode>.alloc(1)
    node.memory.next = UnsafeMutablePointer.null()
    let item = UnsafeMutablePointer<T>.alloc(1)
    item.initialize(newElement)
    node.memory.elem = COpaquePointer(item)

    OSAtomicFifoEnqueue(head, node, 0)
    OSAtomicIncrement32Barrier(size)
  }

  public func dequeue() -> T?
  {
    if OSAtomicDecrement32Barrier(size) >= 0
    {
      let node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(head, 0))
      let item = UnsafeMutablePointer<T>(node.memory.elem)
      let element = item.move()
      item.dealloc(1)
      node.dealloc(1)
      return element
    }
    else
    { // We decremented once too many; increment once to correct.
      OSAtomicIncrement32Barrier(size)
      return nil
    }
  }

  public func next() -> T?
  {
    return dequeue()
  }

  public func generate() -> PointerQueue2<T>
  {
    return self
  }
}

final private class QueueDeallocator<T>
{
  private let head: COpaquePointer
  private let size: UnsafeMutablePointer<Int32>

  init(head: COpaquePointer, size: UnsafeMutablePointer<Int32>)
  {
    self.head = head
    self.size = size
  }

  deinit
  {
    // first, empty the queue
    var s = PointerNodeCountNodes(head)
    while s > 0
    {
      let node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(head, 0))
      let item = UnsafeMutablePointer<T>(node.memory.elem)
      item.destroy()
      item.dealloc(1)
      node.dealloc(1)
      s -= 1
    }

    // then release the queue head structure
    AtomicQueueRelease(head)
    size.destroy()
    size.dealloc(1)
  }
}
