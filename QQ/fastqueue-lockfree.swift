//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

/**
  Lock-free queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
  "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
  in Principles of Distributed Computing '96 (PODC96)
*/

final public class LockFreeFastQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head = Int64()
  private var tail = Int64()

  private let pool = AtomicStackInit()

  public init()
  {
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.memory = Node(UnsafeMutablePointer<T>.alloc(1))
    head.reset(node)
    tail.reset(node)
  }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    // empty the queue
    let emptyhead = UnsafeMutablePointer<Node<T>>(head.pointer)
    head = emptyhead.memory.next
    emptyhead.memory.elem.dealloc(1)
    emptyhead.dealloc(1)

    while head.pointer != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(head.pointer)
      head = node.memory.next
      node.memory.elem.destroy()
      node.memory.elem.dealloc(1)
      node.dealloc(1)
    }

    // drain the pool
    while UnsafePointer<COpaquePointer>(pool).memory != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(OSAtomicDequeue(pool, 0))
      node.memory.elem.dealloc(1)
      node.dealloc(1)
    }
    AtomicStackRelease(pool)
  }

  public var isEmpty: Bool { return head.pointer == nil }

  public var count: Int {
    return head.pointer == nil ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // Not thread safe.

    var i = 0
    var node = UnsafeMutablePointer<Node<T>>(head.pointer).memory.next
    while node.pointer != nil
    { // Iterate along the linked nodes while counting
      node = UnsafeMutablePointer<Node<T>>(node.pointer).memory.next
      i++
    }

    return i
  }

  public func enqueue(newElement: T)
  {
    var node = UnsafeMutablePointer<Node<T>>(OSAtomicDequeue(pool, 0))
    if node == nil
    {
      node = UnsafeMutablePointer<Node<T>>.alloc(1)
      node.memory.elem = UnsafeMutablePointer<T>.alloc(1)
    }
    node.memory.next.reset()
    node.memory.elem.initialize(newElement)

    while true
    {
      let oldtail = tail
      let oldnext = UnsafeMutablePointer<Node<T>>(oldtail.pointer).memory.next
      if oldtail == tail
      { // was tail pointing to the last node?
        if oldnext.pointer == nil
        { // try to link the new node to the end of the list
          if UnsafeMutablePointer<Node<T>>(tail.pointer).memory.next.atomicSet(old: oldnext, new: node)
          { // success
            break
          }
        }
        else
        {  // tail wasn't pointing to the actual last node; try to fix it.
          tail.atomicSet(old: oldtail, new: oldnext.pointer)
        }
      }
    }
    // enqueued. try to have tail point to the inserted node.
    tail.atomicSet(old: tail, new: node)
  }

  public func dequeue() -> T?
  {
    var oldhead = head
    var pointer = UnsafeMutablePointer<T>()
    while true
    {
      let oldtail = tail
      let next = UnsafePointer<Node<T>>(head.pointer).memory.next

      if oldhead == head
      {
        if oldhead.pointer == oldtail.pointer
        {
          if next.pointer == nil
          { // queue is empty
            return nil
          }
          // tail is not pointing to the right node
          tail.atomicSet(old: tail, new: next.pointer)
        }
        else
        { // no need to deal with tail
          pointer = UnsafePointer<Node<T>>(next.pointer).memory.elem
          if head.atomicSet(old: oldhead, new: next.pointer)
          {
            break
          }
        }
      }

      oldhead = head
    }

    let element = pointer.move()
    OSAtomicEnqueue(pool, oldhead.pointer, 0)
    return element
  }

  public func next() -> T?
  {
    return dequeue()
  }

  public func generate() -> Self
  {
    return self
  }
}

private struct Node<T>
{
  var next: Int64
  var elem: UnsafeMutablePointer<T>

  init(_ p: UnsafeMutablePointer<T>)
  {
    next = 0
    elem = p
  }
}

private extension Int64
{
  mutating func reset()
  {
    self = 0
  }

  mutating func reset<T>(pointer: UnsafeMutablePointer<Node<T>>)
  {
    self = unsafeBitCast(pointer, Int64.self)
  }

  mutating func atomicSet(#old: Int64, new: UnsafeMutablePointer<Void>) -> Bool
  {
    let optr = self

    #if arch(x86_64) || arch(arm64)
      let oldtag = optr >> 56 & 0xff
      let newtag = (oldtag+1) & 0xff

      let nptr = unsafeBitCast(new, Int64.self) & 0x00ff_ffff_ffff_ffff + (newtag << 56)

      return OSAtomicCompareAndSwap64Barrier(old, nptr, &self)
    #else // 32-bit architecture
      let oldtag = optr >> 32 & 0xffffffff
      let newtag = (oldtag+1) & 0xffffffff

      let nptr = Int64(unsafeBitCast(new, UInt32.self)) + (newtag << 32)

      return OSAtomicCompareAndSwap64Barrier(old, nptr, &self)
    #endif
  }

  var pointer: UnsafeMutablePointer<Void> {
    #if arch(x86_64) || arch(arm64)
      if self & 0x80_0000_0000_0000 == 0
      { return UnsafeMutablePointer(bitPattern: UWord(self & 0x00ff_ffff_ffff_ffff)) }
      else
      { return UnsafeMutablePointer(bitPattern: UWord(self & 0x00ff_ffff_ffff_ffff) + 0xff00_0000_0000_0000) }
    #else // 32-bit architecture
      return UnsafeMutablePointer(bitPattern: UWord(self && 0xffff_ffff))
    #endif
  }
}
