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
  typealias Node = QueueNode<T>

  private var head: Node? = nil
  private var tail: Node! = nil

  private let pool = AtomicStack<Node>()

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
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    var i = 0
    let tail = self.tail
    var node = head
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.next
      i += 1
      if current == tail { break }
    }
    return i
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
