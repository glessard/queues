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

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    deallocator = QueueDeallocator(head: head)
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
    // Not thread safe.
    return AtomicQueueCountNodes(head, 0)
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<LinkNode>.alloc(1)
    node.memory.next = nil
    let elem = UnsafeMutablePointer<T>.alloc(1)
    elem.initialize(newElement)
    node.memory.elem = COpaquePointer(elem)

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> T?
  {
    let node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(head, 0))
    if node != nil
    {
      let elem = UnsafeMutablePointer<T>(node.memory.elem)
      let element = elem.move()
      elem.dealloc(1)
      node.dealloc(1)
      return element
    }

    // The queue is empty
    return nil
  }

  public func next() -> T?
  {
    return dequeue()
  }

  public func generate() -> PointerQueue2
  {
    return self
  }
}

final private class QueueDeallocator<T>
{
  private let head: COpaquePointer

  init(head: COpaquePointer)
  {
    self.head = head
  }

  deinit
  {
    // first, empty the queue
    while UnsafeMutablePointer<COpaquePointer>(head).memory != nil
    {
      let node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(head, 0))
      let item = UnsafeMutablePointer<T>(node.memory.elem)
      item.destroy()
      item.dealloc(1)
      node.dealloc(1)
    }

    // then release the queue head structure
    AtomicQueueRelease(head)
  }
}
