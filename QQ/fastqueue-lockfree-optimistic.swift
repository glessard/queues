//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

/**
  Lock-free queue algorithm adapted from Edya Ladan-Mozes and Nir Shavit,
  "An optimistic approach to lock-free FIFO queues",
  Distributed Computing (2008) 20:323-341; DOI 10.1007/s00446-007-0050-0

  See also:
  Proceedings of the 18th International Conference on Distributed Computing (DISC) 2004
  http://people.csail.mit.edu/edya/publications/OptimisticFIFOQueue-DISC2004.pdf
*/

final public class OptimisticFastQueue<T>: QueueType, SequenceType, GeneratorType
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

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    return (head == tail) ? 0 : countElements()
  }

  public func countElements() -> Int
  {
    // make sure the `next` pointers are in order
    fixlist(tail: tail, head: head)

    var i = 0
    var nodepointer = UnsafePointer<Node<T>>(head.pointer).memory.next.pointer
    while nodepointer != nil
    { // Iterate along the linked nodes while counting
      nodepointer = UnsafePointer<Node<T>>(nodepointer).memory.next.pointer
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
      let oldtag  = oldtail.tag

      node.memory.prev.set(oldpntr, tag: oldtag+1)
      if tail.atomicSet(old: oldtail, new: node)
      {
        oldpntr.memory.next.set(node, tag: oldtag)
        break
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
        if oldhead != oldtail
        {
          if newhead.tag != oldhead.tag
          {
            fixlist(tail: oldtail, head: oldhead)
          }
          else
          {
            let newpntr = UnsafeMutablePointer<Node<T>>(newhead.pointer)
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
        }
        else
        {
          return nil
        }
      }
    }
  }

  private func fixlist(tail oldtail: Int64, head oldhead: Int64)
  {
    var current = oldtail
    while oldhead == head && current != oldhead
    {
      let pptr = UnsafePointer<Node<T>>(current.pointer).memory.prev.pointer
      UnsafeMutablePointer<Node<T>>(pptr).memory.next.set(current.pointer, tag: current.tag-1)
      current.set(pptr, tag: current.tag-1)
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
  var prev: Int64 = 0
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
      let oldtag = UInt64(bitPattern: old) >> 56
      let newtag = (oldtag+1) << 56

      let nptr = Int64(bitPattern: unsafeBitCast(new, UInt64.self) & 0x00ff_ffff_ffff_ffff + newtag)

      return OSAtomicCompareAndSwap64Barrier(old, nptr, &self)
    #else // 32-bit architecture
      let oldtag = UInt64(bitPattern: old) >> 32
      let newtag = (oldtag+1) << 32

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
