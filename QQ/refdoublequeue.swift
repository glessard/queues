//
//  refqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

public final class RefDoubleQueue<T: AnyObject>: QueueType, SequenceType, GeneratorType
{
  private let head = AtomicQueueInit()
  private let pool = AtomicQueueInit()
  private var size: Int32 = 0

  public init() { }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    // first, empty the main queue
    while size > 0
    {
      dequeue()
    }
    // then release the queue head structure
    AtomicQueueRelease(head)

    // then empty the pool queue
    var count = RefNodeCountNodes(pool)
    while count > 0
    {
      RefNodeDequeue(pool)
      count -= 1
    }
    AtomicQueueRelease(pool)
  }

  public var isEmpty: Bool { return size < 1 }

  public var count: Int { return Int(size) }

  public func CountNodes() -> Int
  {
    return RefNodeCountNodes(head)
  }

  public func enqueue(item: T)
  {
    RefNodeEnqueue2(head, pool, item)
    OSAtomicIncrement32Barrier(&size)
  }

  public func dequeue() -> T?
  {
    if OSAtomicDecrement32Barrier(&size) >= 0
    {
      return RefNodeDequeue2(head, pool) as? T
    }
    else
    { // We decremented once too many; increment once to correct.
      OSAtomicIncrement32Barrier(&size)
      return nil
    }
  }

  // Implementation of GeneratorType

  public func next() -> T?
  {
    return dequeue()
  }

  // Implementation of SequenceType

  public func generate() -> Self
  {
    return self
  }
}
