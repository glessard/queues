//
//  pointerqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

public final class RefQueueSwift1<T: AnyObject>: QueueType
{
  private let head = AtomicQueueInit()
  private var size: Int32 = 0

  public init() { }

  convenience public init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    // first, empty the queue
    while size > 0
    {
      dequeue()
    }

    // then release the queue head structure
    AtomicQueueRelease(head)
  }

  public var isEmpty: Bool { return size < 1 }

  public var count: Int { return Int(size) }

  public func CountNodes() -> Int
  {
    return PointerNodeCountNodes(head)
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<PointerNode>.alloc(1)
    node.memory.next = nil
    let elem = Unmanaged.passRetained(newElement).toOpaque()
    node.memory.elem = UnsafeMutablePointer<Void>(elem)

    OSAtomicFifoEnqueue(head, node, 0)
    OSAtomicIncrement32Barrier(&size)
  }

  public func dequeue() -> T?
  {
    if OSAtomicDecrement32Barrier(&size) >= 0
    {
      let node = UnsafeMutablePointer<PointerNode>(OSAtomicFifoDequeue(head, 0))
      let item = COpaquePointer(node.memory.elem)
      let element = Unmanaged<T>.fromOpaque(item).takeRetainedValue()
      node.dealloc(1)
      return element
    }
    else
    { // We decremented once too many; increment once to correct.
      OSAtomicIncrement32Barrier(&size)
      return nil
    }
  }
}
