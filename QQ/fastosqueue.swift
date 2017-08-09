//
//  fastosqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

final public class FastOSQueue<T>: QueueType
{
  public typealias Element = T

  private let queue = AtomicQueue<QueueNode<T>>()
  private let pool = AtomicStack<QueueNode<T>>()

  public init() { }

  deinit
  {
    // empty the queue
    while let node = queue.dequeue()
    {
      node.deinitialize()
      node.deallocate()
    }
    // release the queue head structure
    queue.release()

    // drain the pool
    while let node = pool.pop()
    {
      node.deallocate()
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
    let node = pool.pop() ?? QueueNode()
    node.initialize(to: newElement)

    queue.enqueue(node)
  }

  public func dequeue() -> T?
  {
    if let node = queue.dequeue()
    {
      let element = node.move()
      pool.push(node)
      return element
    }

    // The queue is empty
    return nil
  }
}
