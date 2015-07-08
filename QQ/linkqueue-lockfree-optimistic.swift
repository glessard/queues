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

final public class OptimisticLinkQueue<T>: QueueType
{
  private var head = Int64()
  private var tail = Int64()

  public init()
  {
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.memory = Node(nil)
    head.set(node, tag: 1)
    tail.set(node, tag: 1)
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
  }

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    if head == tail { return 0 }

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
    let node = UnsafeMutablePointer<Node<T>>.alloc(1)
    node.memory = Node(UnsafeMutablePointer<T>.alloc(1))
    node.memory.elem.initialize(newElement)

    while true
    {
      let oldtail = tail
      let oldpntr = UnsafeMutablePointer<Node<T>>(oldtail.pointer)
      let oldtag  = oldtail.tag

      node.memory.prev.set(oldpntr, tag: oldtag+1)
      if tail.CAS(old: oldtail, new: node)
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
          if newhead == 0 || newhead.tag != oldhead.tag
          {
            fixlist(tail: oldtail, head: oldhead)
          }
          else
          {
            let newpntr = UnsafeMutablePointer<Node<T>>(newhead.pointer)
            let element = newpntr.memory.elem.memory
            if head.CAS(old: oldhead, new: newpntr)
            {
              let eptr = oldpntr.memory.elem
              if eptr != nil
              {
                eptr.destroy()
              }

              oldpntr.dealloc(1)
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
      let prevptr = UnsafeMutablePointer<Node<T>>(UnsafePointer<Node<T>>(current.pointer).memory.prev.pointer)
      prevptr.memory.next.set(current.pointer, tag: current.tag-1)
      current.set(prevptr, tag: current.tag-1)
    }
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
      return UnsafeMutablePointer(bitPattern: UWord(self & 0x00ff_ffff_ffff_ffff))
    #else // 32-bit architecture
      return UnsafeMutablePointer(bitPattern: UWord(self & 0xffff_ffff))
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
