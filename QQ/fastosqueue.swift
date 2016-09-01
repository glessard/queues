//
//  fastosqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

final public class FastOSQueue<T>: QueueType
{
  private let queue = AtomicQueue<Node<T>>()
  private let pool = AtomicStack<Node<T>>()

  public init() { }

  deinit
  {
    // empty the queue
    while let node = queue.dequeue()
    {
      node.deinitialize()
      node.deallocate(capacity: 1)
    }
    // release the queue head structure
    queue.release()

    // drain the pool
    while let node = pool.pop()
    {
      node.deallocate(capacity: 1)
    }
    // release the pool stack structure
    pool.release()
  }

  public var isEmpty: Bool {
    return queue.isEmpty
  }

  public var count: Int {
    return queue.count
  }

  public func enqueue(_ newElement: T)
  {
    let node = pool.pop() ?? UnsafeMutablePointer.allocate(capacity: 1)
    node.initialize(to: Node(newElement))

    queue.enqueue(node)
  }

  public func dequeue() -> T?
  {
    if let node = queue.dequeue()
    {
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
