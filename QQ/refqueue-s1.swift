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
      let node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(head, 0))
      Unmanaged<T>.fromOpaque(node.memory.elem).release()
      node.dealloc(1)
    }

    // then release the queue head structure
    AtomicQueueRelease(head)
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
    var nptr = UnsafeMutablePointer<UnsafeMutablePointer<LinkNode>>(head).memory
    while nptr != nil
    { // Iterate along the linked nodes while counting
      nptr = nptr.memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<LinkNode>.alloc(1)
    node.memory.next = nil
    node.memory.elem = Unmanaged.passRetained(newElement).toOpaque()

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> T?
  {
    let node = UnsafeMutablePointer<LinkNode>(OSAtomicFifoDequeue(head, 0))
    if node != nil
    {
      let element = Unmanaged<T>.fromOpaque(node.memory.elem).takeRetainedValue()
      node.dealloc(1)
      return element
    }

    return nil
  }
}
