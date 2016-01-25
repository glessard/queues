//
//  LinkOSQueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

final public class LinkOSQueue<T>: QueueType
{
  private let head = AtomicQueueInit()

  public init() { }

  deinit
  {
    // empty the queue
    while UnsafeMutablePointer<COpaquePointer>(head).memory != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(OSAtomicFifoDequeue(head, 0))
      node.destroy()
      node.dealloc(1)
    }
    // release the queue head structure
    AtomicQueueRelease(head)
  }

  public var isEmpty: Bool {
    return UnsafeMutablePointer<COpaquePointer>(head).memory == nil
  }

  public var count: Int {
    var i = 0
    var node = UnsafeMutablePointer<UnsafeMutablePointer<Node<T>>>(head).memory
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i += 1
    }
    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.initialize(Node(newElement))

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> T?
  {
    let node = UnsafeMutablePointer<Node<T>>(OSAtomicFifoDequeue(head, 0))
    if node != nil
    {
      let element = node.memory.elem
      node.destroy()
      node.dealloc(1)
      return element
    }

    // The queue is empty
    return nil
  }
}

private struct Node<T>
{
  var next: UnsafeMutablePointer<Node<T>> = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }
}
