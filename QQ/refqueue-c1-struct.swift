//
//  refqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

public struct RefQueueStruct<T: AnyObject>: QueueType, SequenceType, GeneratorType
{
  private let head = AtomicQueueInit()
  private var size = UnsafeMutablePointer<Int32>.alloc(1)

  private let deallocator: QueueDeallocator<T>

  public init()
  {
    size.initialize(0)
    deallocator = QueueDeallocator(head: head, size: size)
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
    RefNodeEnqueue(head, item)
    OSAtomicIncrement32Barrier(size)
  }

  public func dequeue() -> T?
  {
    if OSAtomicDecrement32Barrier(size) >= 0
    {
      return RefNodeDequeue(head) as? T
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

  public func generate() -> RefQueueStruct<T>
  {
    return self
  }
}

final private class QueueDeallocator<T>
{
  private let head: COpaquePointer
  private let size: UnsafeMutablePointer<Int32>

  init(head: COpaquePointer, size: UnsafeMutablePointer<Int32>)
  {
    self.head = head
    self.size = size
  }

  deinit
  {
    // first, empty the queue
    for var count = RefNodeCountNodes(head); count > 0; count--
    {
      RefNodeDequeue(head)
    }
    // then release the queue head structure
    AtomicQueueRelease(head)

    size.destroy()
    size.dealloc(1)
  }
}
