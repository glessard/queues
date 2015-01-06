//
//  refqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

private let offset = RefNodeLinkOffset()
private let length = RefNodeSize()

public final class RefQueueSwift3<T: AnyObject>: QueueType
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
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.initialize(Node(item))

    OSAtomicFifoEnqueue(head, node, offset)
    OSAtomicIncrement32Barrier(&size)
  }

  public func dequeue() -> T?
  {
    if OSAtomicDecrement32Barrier(&size) >= 0
    {
      let node = UnsafeMutablePointer<Node<T>>(OSAtomicFifoDequeue(head, offset))
      let element = node.memory.item.takeRetainedValue()
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

private struct Node<T: AnyObject>
{
  var next = COpaquePointer.null()
  let item: Unmanaged<T>

  init(_ newElement: T)
  {
    item = Unmanaged.passRetained(newElement)
  }
}
