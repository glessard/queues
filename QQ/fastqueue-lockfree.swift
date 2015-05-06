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
  See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html
*/

final public class LockFreeFastQueue<T>: QueueType, SequenceType, GeneratorType
{
  private var head = Int64()
  private var tail = Int64()

  private let pool = AtomicStackInit()

  public init()
  {
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.memory = Node(nil)
    head.set(node, tag: 0)
    tail.set(node, tag: 0)
  }

  public convenience init(_ newElement: T)
  {
    self.init()
    enqueue(newElement)
  }

  deinit
  {
    // empty the queue
    while head.pointer != nil
    {
      let node = UnsafeMutablePointer<Node<T>>(head.pointer)
      head = node.memory.next
      if node.memory.elem != nil
      {
        node.memory.elem.destroy()
        node.memory.elem.dealloc(1)
      }
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

  public var isEmpty: Bool { return head.pointer == tail.pointer }

  public var count: Int {
    return head.pointer == tail.pointer ? 0 : countElements()
  }

  public func countElements() -> Int
  {
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
      let oldpntr = UnsafeMutablePointer<Node<T>>(oldtail.pointer)
      let oldnext = oldpntr.memory.next

      if oldtail == tail
      { // was tail pointing to the last node?
        if oldnext.pointer == nil
        { // try to link the new node to the end of the list
          if oldpntr.memory.next.atomicSet(old: oldnext, new: node)
          { // success. try to have tail point to the inserted node.
            tail.atomicSet(old: oldtail, new: node)
            break
          }
        }
        else
        { // tail wasn't pointing to the actual last node; try to fix it.
          tail.atomicSet(old: oldtail, new: oldnext.pointer)
        }
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let oldhead = head
      let oldpntr = UnsafeMutablePointer<Node<T>>(oldhead.pointer)

      let oldtail = tail
      let newhead = oldpntr.memory.next

      if oldhead == head
      {
        let newpntr = UnsafePointer<Node<T>>(newhead.pointer)

        if oldpntr != oldtail.pointer
        { // no need to deal with tail
          let element = newpntr.memory.elem.memory
          if head.atomicSet(old: oldhead, new: newpntr)
          {
            let eptr = oldpntr.memory.elem
            if eptr != nil
            {
              eptr.destroy()
              OSAtomicEnqueue(pool, oldpntr, 0)
            }
            else
            {
              oldpntr.dealloc(1)
            }
            return element
          }
        }
        else
        {
          if newpntr == nil
          { // queue is empty
            return nil
          }
          // tail is not pointing to the correct last node; try to fix it.
          tail.atomicSet(old: oldtail, new: newpntr)
        }
      }
    }
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
  var sptr: Int   = 0
  var next: Int64 = 0
  var elem: UnsafeMutablePointer<T>

  init(_ p: UnsafeMutablePointer<T>)
  {
    elem = p
  }
}

/**
  Int64 as tagged pointer, as a strategy to overcome the ABA problem in
  synchronization algorithms based on atomic compare-and-swap operations.

  The implementation uses Int64 as the base type in order to easily
  work with OSAtomicCompareAndSwap in Swift.
*/

private extension Int64
{
  mutating func reset()
  {
    self = 0
  }

//  mutating func set(pointer: UnsafePointer<Void>)
//  {
//    set(pointer, tag: self.tag+1)
//  }

  mutating func set(pointer: UnsafePointer<Void>, tag: Int64)
  {
    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
      let newtag = UInt64(bitPattern: tag) << 56
      self = Int64(bitPattern: unsafeBitCast(pointer, UInt64.self) & 0x00ff_ffff_ffff_ffff + newtag)
      #else
      let newtag = UInt64(bitPattern: tag) << 32
      self = Int64(bitPattern: UInt64(unsafeBitCast(pointer, UInt32.self)) + newtag)
    #endif
  }
  
  mutating func atomicSet(#old: Int64, new: UnsafePointer<Void>) -> Bool
  {
    if old != self { return false }
    
    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
      let oldtag = UInt64(bitPattern: old) >> 56  & 0xff
      let newtag = ((oldtag+1) & 0xff) << 56

      let nptr = Int64(bitPattern: (unsafeBitCast(new, UInt64.self) & 0x00ff_ffff_ffff_ffff) + newtag)

      return OSAtomicCompareAndSwap64Barrier(old, nptr, &self)
    #else // 32-bit architecture
      let oldtag = UInt64(bitPattern: old) >> 32 & 0xffffffff
      let newtag = ((oldtag+1) & 0xffffffff) << 32

      let nptr = Int64(bitPattern: UInt64(unsafeBitCast(new, UInt32.self)) + newtag)

      return OSAtomicCompareAndSwap64Barrier(old, nptr, &self)
    #endif
  }

  var pointer: UnsafeMutablePointer<Void> {
    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
      if self & 0x80_0000_0000_0000 == 0
      { return UnsafeMutablePointer(bitPattern: UWord(self & 0x00ff_ffff_ffff_ffff)) }
      else // an upper-half pointer
      { return UnsafeMutablePointer(bitPattern: UWord(self & 0x00ff_ffff_ffff_ffff) + 0xff00_0000_0000_0000) }
    #else // 32-bit architecture
      return UnsafeMutablePointer(bitPattern: UWord(self && 0xffff_ffff))
    #endif
  }

  var tag: Int64 {
    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
      return Int64(bitPattern: UInt64(bitPattern: self) >> 56)
    #else // 32-bit architecture
      return Int64(bitPattern: UInt64(bitPattern: self) >> 32)
    #endif
  }
}
