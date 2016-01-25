//
//  queue-unsafe.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

/// An ARC-based queue with no thread safety.

final public class UnsafeQueue<T>: QueueType
{
  private var head: Node<T>? = nil
  private var tail: Node<T>! = nil

  public init() { }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    // Not thread safe.
    var i = 0
    var node = head
    while let n = node
    { // Iterate along the linked nodes while counting
      node = n.next
      i++
    }
    return i
  }

  public func enqueue(newElement: T)
  {
    let node = Node(newElement)

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
      // Promote the 2nd node to 1st
      head = node.next

      // Logical housekeeping
      if head == nil { tail = nil }

      return node.elem
    }

    // queue is empty
    return nil
  }
}

/**
  A simple Node for the Queue implemented above.
  Clearly an implementation detail.
*/

private class Node<T>
{
  var next: Node? = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }
}
