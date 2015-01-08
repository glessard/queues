//
//  refqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

public struct RefQueueStruct<T: AnyObject>: QueueType
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

  public func enqueue(item: T)
  {
    let node = UnsafeMutablePointer<ObjLinkNode>.alloc(1)
    node.initialize(ObjLinkNode(item))

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> T?
  {
    let node = UnsafeMutablePointer<ObjLinkNode>(OSAtomicFifoDequeue(head, 0))
    if node != nil
    {
      let element = node.memory.elem as? T
      node.destroy()
      node.dealloc(1)
      return element
    }

    return nil
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
      let node = UnsafeMutablePointer<ObjLinkNode>(OSAtomicFifoDequeue(head, 0))
      node.destroy()
      node.dealloc(1)
    }

    // then release the queue head structure
    AtomicQueueRelease(head)
  }
}
