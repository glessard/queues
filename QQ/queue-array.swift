//
//  queue-array.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

/// An Array-based queue with no thread safety.

final public class ArrayQueue<T>: QueueType
{
  public typealias Element = T

  private var elements: Array<T>

  public init() { elements = [] }

  public var isEmpty: Bool { return elements.isEmpty }

  public var count: Int { return elements.count }

  public func enqueue(_ newElement: T)
  {
    elements.append(newElement)
  }

  public func dequeue() -> T?
  {
    guard let element = elements.first else { return nil }

    elements.remove(at: 0)
    return element
  }
}
