//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

/**
  Two-lock queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
  "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
  in Principles of Distributed Computing '96 (PODC96)
  See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html
*/

final public class Link2LockQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head: UnsafeMutablePointer<Node<T>> = nil
  private var tail: UnsafeMutablePointer<Node<T>> = nil

  private var hlock = OS_SPINLOCK_INIT
  private var tlock = OS_SPINLOCK_INIT

  public init()
  {
    head = UnsafeMutablePointer<Node<T>>.alloc(1)
    head.memory = Node(UnsafeMutablePointer<T>.alloc(1))
    tail = head
  }

  deinit
  {
    // empty the queue
    let emptyhead = head
    head = head.memory.next
    emptyhead.memory.elem.dealloc(1)
    emptyhead.dealloc(1)

    while head != nil
    {
      let node = head
      head = node.memory.next
      node.memory.elem.destroy()
      node.memory.elem.dealloc(1)
      node.dealloc(1)
    }
  }

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    var i = 0
    var node = head.memory.next
    while node != nil
    { // Iterate along the linked nodes while counting
      node = node.memory.next
      i++
    }
    return i
  }

  public func enqueue(newElement: T)
  {
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.memory = Node(UnsafeMutablePointer<T>.alloc(1))
    node.memory.elem.initialize(newElement)

    OSSpinLockLock(&tlock)
    tail.memory.next = node
    tail = node
    OSSpinLockUnlock(&tlock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&hlock)
    let next = head.memory.next
    if next != nil
    {
      let oldhead = head
      head = next
      let element = next.memory.elem.move()
      OSSpinLockUnlock(&hlock)

      oldhead.memory.elem.dealloc(1)
      oldhead.dealloc(1)
      return element
    }

    // queue is empty
    OSSpinLockUnlock(&hlock)
    return nil
  }
}

private struct Node<T>
{
  var nptr: UnsafeMutablePointer<Void> = nil
  let elem: UnsafeMutablePointer<T>

  init(_ p: UnsafeMutablePointer<T>)
  {
    elem = p
  }

  var next: UnsafeMutablePointer<Node<T>> {
    get { return UnsafeMutablePointer(nptr) }
    set { nptr = UnsafeMutablePointer(newValue) }
  }
}
