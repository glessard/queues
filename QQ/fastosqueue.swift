//
//  fastosqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

final public class FastOSQueue<T>: QueueType
{
  private let head = AtomicQueueInit()
  private let pool = AtomicStack<Node<T>>()

  public init() { }

  deinit
  {
    // empty the queue
    while UnsafePointer<OpaquePointer?>(head).pointee != nil
    {
      let node = OSAtomicFifoDequeue(head, 0).assumingMemoryBound(to: Node<T>.self)
      node.deinitialize()
      node.deallocate(capacity: 1)
    }
    // release the queue head structure
    AtomicQueueRelease(head)

    // drain the pool
    while let node = pool.pop()
    {
      node.deallocate(capacity: 1)
    }
    // release the pool stack structure
    pool.release()
  }

  public var isEmpty: Bool {
    return UnsafePointer<OpaquePointer?>(head).pointee == nil
  }

  public var count: Int {
    var i = 0
    var node = UnsafePointer<UnsafeMutablePointer<Node<T>>?>(head).pointee
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.pointee.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = pool.pop() ?? UnsafeMutablePointer.allocate(capacity: 1)
    node.initialize(to: Node(newElement))

    OSAtomicFifoEnqueue(head, node, 0)
  }

  public func dequeue() -> T?
  {
    if let raw = OSAtomicFifoDequeue(head, 0)
    {
      let node = raw.assumingMemoryBound(to: Node<T>.self)
      let element = node.pointee.elem
      node.deinitialize()
      pool.push(node)
      return element
    }

    // The queue is empty
    return nil
  }
}

private struct Node<T>
{
  var next: UnsafeMutablePointer<Node<T>>? = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }
}
