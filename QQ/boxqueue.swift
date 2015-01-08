//
//  boxqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

public final class BoxQueue<T>: QueueType
{
  private let head = AtomicQueueInit()
  private var size: Int32 = 0

  public init() { }

  convenience public init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    // first, empty the queue
    while size > 0
    {
      dequeue()
    }

    // then release the queue head structure
    AtomicQueueRelease(head)
  }

  public var isEmpty: Bool { return size < 1 }

  public var count: Int { return Int(size) }

  public func CountNodes() -> Int
  {
    return RefNodeCountNodes(head)
  }

  public func enqueue(item: T)
  {
    RefNodeEnqueue(head, Box(item))
    OSAtomicIncrement32Barrier(&size)
  }

  public func dequeue() -> T?
  {
    if OSAtomicDecrement32Barrier(&size) >= 0
    {
      let box = RefNodeDequeue(head) as? Box
      return box?.element as T?
    }
    else
    { // We decremented once too many; increment once to correct.
      OSAtomicIncrement32Barrier(&size)
      return nil
    }
  }
}


/**
  A simple Box for the Queue implemented above.
  Clearly an implementation detail.
*/

private class Box
{
  let element: Any

  init(_ e: Any)
  {
    element = e
  }
}
