//
//  refqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

public struct RefDoubleQueueStruct<T: AnyObject>: QueueType, SequenceType, GeneratorType
{
  private let head = AtomicQueueInit()
  private let pool = AtomicQueueInit()
  private let size = UnsafeMutablePointer<Int32>.alloc(1)

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    size.initialize(0)
    deallocator = QueueDeallocator(head: head, pool: pool, size: size)
  }

  public init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  public var isEmpty: Bool { return size.memory < 1 }

  public var count: Int { return Int(size.memory) }

  public func CountNodes() -> Int
  {
    return RefNodeCountNodes(head)
  }

  public func enqueue(item: T)
  {
    RefNodeEnqueue2(head, pool, item)
    OSAtomicIncrement32Barrier(size)
  }

  public func dequeue() -> T?
  {
    if OSAtomicDecrement32Barrier(size) >= 0
    {
      return RefNodeDequeue2(head, pool) as? T
    }
    else
    { // We decremented once too many; increment once to correct.
      OSAtomicIncrement32Barrier(size)
      return nil
    }
  }

  // Implementation of GeneratorType

  public func next() -> T?
  {
    return dequeue()
  }

  // Implementation of SequenceType

  public func generate() -> RefDoubleQueueStruct<T>
  {
    return self
  }
}

final private class QueueDeallocator<T>
{
  private let head: COpaquePointer
  private let pool: COpaquePointer
  private let size: UnsafeMutablePointer<Int32>

  init(head: COpaquePointer, pool: COpaquePointer, size: UnsafeMutablePointer<Int32>)
  {
    self.head = head
    self.pool = pool
    self.size = size
  }

  deinit
  {
    // first, empty the queue
    for var count = RefNodeCountNodes(head); count > 0; count--
    {
      RefNodeDequeue2(head, pool)
    }
    // release the queue head structure
    AtomicQueueRelease(head)

    // Then, drain the pool
    for var count = RefNodeCountNodes(pool); count > 0; count--
    {
      RefNodeDequeue(pool)
    }
    // release the pool queue structure
    AtomicQueueRelease(pool)

    size.destroy()
    size.dealloc(1)
  }
}
