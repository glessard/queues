//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import func Darwin.libkern.OSAtomic.OSAtomicEnqueue
import func Darwin.libkern.OSAtomic.OSAtomicDequeue

final public class UnsafeFastQueue<T>: QueueType
{
  private var head: UnsafeMutablePointer<Node<T>>? = nil
  private var tail: UnsafeMutablePointer<Node<T>> = UnsafeMutablePointer(bitPattern: 0x0000000f)!

  private let pool = AtomicStackInit()

  public init() { }

  deinit
  {
    // empty the queue
    while head != nil
    {
      let node = head
      head = node?.pointee.next
      node?.deinitialize()
      node?.deallocate(capacity: 1)
    }

    // drain the pool
    while UnsafePointer<OpaquePointer?>(pool).pointee != nil
    {
      let node = OSAtomicDequeue(pool, 0).assumingMemoryBound(to: Node<T>.self)
      node.deallocate(capacity: 1)
    }
    // release the pool stack structure
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool { return head == nil }

  public var count: Int {
    var i = 0
    var node = head
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node?.pointee.next
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node: UnsafeMutablePointer<Node<T>>
    if let raw = OSAtomicDequeue(pool, 0)
    {
      node = raw.assumingMemoryBound(to: Node<T>.self)
    }
    else
    {
      node = UnsafeMutablePointer<Node<T>>.allocate(capacity: 1)
    }
    node.initialize(to: Node(newElement))

    if head == nil
    {
      head = node
      tail = node
    }
    else
    {
      tail.pointee.next = node
      tail = node
    }
  }

  public func dequeue() -> T?
  {
    if let node = head
    { // Promote the 2nd item to 1st
      head = node.pointee.next

      let element = node.pointee.elem
      node.deinitialize()
      OSAtomicEnqueue(pool, node, 0)
      return element
    }

    // queue is empty
    return nil
  }
}

private struct Node<T>
{
  var next: UnsafeMutablePointer<Node<T>>? = nil
  let elem: T

  init(_ e: T)
  {
    elem = e
  }
}
