//
//  queue-unsafe.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

final public class UnsafeQueue<T>: QueueType
{
  public typealias Element = T
  typealias Node = QueueNode<T>

  private var head: Node? = nil
  private var tail: Node! = nil

  public init() { }

  deinit
  {
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

  public func enqueue(_ newElement: T)
  {
    let node = Node(initializedWith: newElement)

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
    {
      head = node.next

      let element = node.move()
      node.deallocate()
      return element
    }

    // queue is empty
    return nil
  }
}
