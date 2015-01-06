//
//  refqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

private let offset = RefNodeLinkOffset()
private let length = RefNodeSize()

public final class RefQueueSwift2<T: AnyObject>: QueueType
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
    return RefNodeCountNodes(head)
  }

  public func enqueue(item: T)
  {
    let node = UnsafeMutablePointer<RefNode>.alloc(1)
    node.initialize(RefNode(next: nil, elem: Unmanaged.passRetained(item)))

    OSAtomicFifoEnqueue(head, node, offset)
    OSAtomicIncrement32Barrier(&size)
  }

  public func dequeue() -> T?
  {
    if OSAtomicDecrement32Barrier(&size) >= 0
    {
      let node = UnsafeMutablePointer<RefNode>(OSAtomicFifoDequeue(head, offset))
      let element = node.memory.elem.takeRetainedValue() as? T
      node.destroy()
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
