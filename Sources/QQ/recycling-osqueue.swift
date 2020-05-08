//
//  recycling-osqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

final public class RecyclingOSQueue<T>: QueueType
{
  public typealias Element = T
  typealias Node = QueueNode<T>

  private let queue = OSAtomicQueue<Node>()
  private let pool = OSAtomicStack<Node>()

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

  private func node(with element: T) -> Node
  {
    if let reused = pool.pop()
    {
      reused.initialize(to: element)
      return reused
    }
    return Node(initializedWith: element)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

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
