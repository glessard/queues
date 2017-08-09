//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

final public class UnsafeFastQueue<T>: QueueType
{
  public typealias Element = T

  private var head: QueueNode<T>? = nil
  private var tail: QueueNode<T>! = nil

  private let pool = AtomicStack<QueueNode<T>>()

  public init() { }

  deinit
  {
    // empty the queue
    while let node = head
    {
      head = node.next
      node.deinitialize()
      node.deallocate()
    }

    // drain the pool
    while let node = pool.pop()
    {
      node.deallocate()
    }
    // release the pool stack structure
    pool.release()
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    var i = 0
    var node = head
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = pool.pop() ?? QueueNode()
    node.initialize(to: newElement)

    if head == nil
    {
      head = node
      tail = node
    }
    else
    {
      tail.next = node
      tail = node
    }
  }

  public func dequeue() -> T?
  {
    if let node = head
    { // Promote the 2nd item to 1st
      head = node.next

      let element = node.move()
      pool.push(node)
      return element
    }

    // queue is empty
    return nil
  }
}
