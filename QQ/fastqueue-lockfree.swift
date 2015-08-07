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

final public class LockFreeFastQueue<T>: QueueType
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
    node.memory.next = 0
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
          if oldpntr.memory.next.CAS(old: oldnext, new: node)
          { // success. try to have tail point to the inserted node.
            tail.CAS(old: oldtail, new: node)
            break
          }
        }
        else
        { // tail wasn't pointing to the actual last node; try to fix it.
          tail.CAS(old: oldtail, new: oldnext.pointer)
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

        if oldpntr != UnsafeMutablePointer<Node<T>>(oldtail.pointer)
        { // no need to deal with tail
          // read element before CAS, otherwise another dequeue racing ahead might free the node too early.
          let element = newpntr.memory.elem.memory
          if head.CAS(old: oldhead, new: newpntr)
          {
            if oldpntr.memory.elem == nil
            {
              oldpntr.memory = Node(UnsafeMutablePointer<T>.alloc(1))
            }
            else
            {
              oldpntr.memory.elem.destroy()
            }
            OSAtomicEnqueue(pool, oldpntr, 0)
            return element
          }
        }
        else
        {
          if newpntr == nil
          { // queue is empty
            return nil
          }
          // tail wasn't pointing to the actual last node; try to fix it.
          tail.CAS(old: oldtail, new: newpntr)
        }
      }
    }
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

@inline(__always) private func TaggedPointer(pointer: UnsafePointer<Void>, tag: Int64) -> Int64
{
  #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
    return Int64(bitPattern: unsafeBitCast(pointer, UInt64.self) & 0x00ff_ffff_ffff_ffff + UInt64(bitPattern: tag) << 56)
  #else
    return Int64(bitPattern: UInt64(unsafeBitCast(pointer, UInt32.self)) + UInt64(bitPattern: tag) << 32)
  #endif
}

private extension Int64
{
  @inline(__always) mutating func set(pointer: UnsafePointer<Void>, tag: Int64)
  {
    self = TaggedPointer(pointer, tag: tag)
  }
  
  @inline(__always) mutating func CAS(old old: Int64, new: UnsafePointer<Void>) -> Bool
  {
    if old != self { return false }
    
    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
      let oldtag = old >> 56
    #else // 32-bit architecture
      let oldtag = old >> 32
    #endif

    let nptr = TaggedPointer(new, tag: oldtag&+1)
    return OSAtomicCompareAndSwap64Barrier(old, nptr, &self)
  }

  var pointer: UnsafeMutablePointer<Void> {
    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
      return UnsafeMutablePointer(bitPattern: UInt(self & 0x00ff_ffff_ffff_ffff))
    #else // 32-bit architecture
      return UnsafeMutablePointer(bitPattern: UInt(self & 0xffff_ffff))
    #endif
  }

//  var tag: Int64 {
//    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
//      return Int64(bitPattern: UInt64(bitPattern: self) >> 56)
//    #else // 32-bit architecture
//      return Int64(bitPattern: UInt64(bitPattern: self) >> 32)
//    #endif
//  }
}
