//
//  LinkOSQueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

final public class LinkOSQueue<T>: QueueType
{
  private let queue = AtomicQueue<QueueNode<T>>()

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
  }

  public var isEmpty: Bool {
    return queue.isEmpty
  }

  public var count: Int {
    return queue.count
  }

  public func enqueue(_ newElement: T)
  {
    let node = QueueNode(initializedWith: newElement)

    queue.enqueue(node)
  }

  public func dequeue() -> T?
  {
    if let node = queue.dequeue()
    {
      let element = node.move()
      node.deallocate()
      return element
    }

    // The queue is empty
    return nil
  }
}
