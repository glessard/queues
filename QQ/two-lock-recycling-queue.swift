//
//  two-lock-recycling-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import let  Darwin.libkern.OSAtomic.OS_SPINLOCK_INIT
import func Darwin.libkern.OSAtomic.OSSpinLockLock
import func Darwin.libkern.OSAtomic.OSSpinLockUnlock

import struct CAtomics.AtomicOptionalMutableRawPointer
import struct CAtomics.AtomicNonNullMutableRawPointer
import struct CAtomics.AtomicTaggedMutableRawPointer
import struct CAtomics.TaggedMutableRawPointer

/// Double-lock queue with node recycling
///
/// Two-lock queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html

final public class TwoLockRecyclingQueue<T>: QueueType
{
  public typealias Element = T
  private typealias Node = Q2Node<T>

  private var hptr = AtomicNonNullMutableRawPointer()
  private var head: Node {
    get { return Node(storage: hptr.load(.relaxed)) }
    set { hptr.store(newValue.storage, .relaxed) }
  }
  private var tail: Node

  private var hlock = OS_SPINLOCK_INIT
  private var tlock = OS_SPINLOCK_INIT

  private var pool = AtomicTaggedMutableRawPointer()

  public init()
  {
    tail = Node.dummy
    hptr.initialize(tail.storage)
    pool.initialize(TaggedMutableRawPointer(tail.storage, tag: 1))
  }

  deinit
  {
    // empty the queue
    var next = head.next
    while let node = next
    {
      next = node.next
      node.deinitialize()
      node.deallocate()
    }
    head.next = nil

    next = Node(storage: pool.load(.acquire).ptr)
    while let node = next
    {
      next = node.next
      node.deallocate()
    }
  }

  public var isEmpty: Bool { return head.storage == tail.storage }

  public var count: Int {
    var i = 0
    let tail = self.tail
    var node = head.next
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.next
      i += 1
      if current == tail { break }
    }
    return i
  }

  private func node(with element: T) -> Node
  {
    var pool = self.pool.load(.acquire)
    while pool.ptr != self.hptr.load(.relaxed)
    {
      let node = Node(storage: pool.ptr)
      if let n = node.next
      {
        let next = pool.incremented(with: n.storage)
        if self.pool.loadCAS(&pool, next, .strong, .acqrel, .acquire)
        {
          node.initialize(to: element)
          return node
        }
      }
      else
      { // this can happen if another thread has succeeded
        // in advancing the pool pointer and has already
        // started initializing the node for enqueueing
        pool = self.pool.load(.acquire)
      }
    }

    return Node(initializedWith: element)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    OSSpinLockLock(&tlock)
    tail.next = node
    tail = node
    OSSpinLockUnlock(&tlock)
  }

  public func dequeue() -> T?
  {
    OSSpinLockLock(&hlock)
    if let next = head.next
    {
      head = next
      let element = next.move()
      OSSpinLockUnlock(&hlock)

      return element
    }

    // queue is empty
    OSSpinLockUnlock(&hlock)
    return nil
  }
}

private let nextOffset = 0

private struct Q2Node<Element>: OSAtomicNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  private var dataOffset: Int {
    return max(MemoryLayout<AtomicOptionalMutableRawPointer>.stride, MemoryLayout<Element>.alignment)
  }

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  private init?(storage: UnsafeMutableRawPointer?)
  {
    guard let storage = storage else { return nil }
    self.storage = storage
  }

  private init()
  {
    let alignment = max(MemoryLayout<AtomicOptionalMutableRawPointer>.alignment, MemoryLayout<Element>.alignment)
    let offset = max(MemoryLayout<AtomicOptionalMutableRawPointer>.stride, MemoryLayout<Element>.alignment)
    let size = offset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+nextOffset).bindMemory(to: AtomicOptionalMutableRawPointer.self, capacity: 1)
    nptr = AtomicOptionalMutableRawPointer(nil)
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1)
  }

  static var dummy: Q2Node { return Q2Node() }

  init(initializedWith element: Element)
  {
    self.init()
    data.initialize(to: element)
  }

  func deallocate()
  {
    storage.deallocate()
  }

  private var nptr: AtomicOptionalMutableRawPointer {
    unsafeAddress {
      return UnsafeRawPointer(storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
    nonmutating unsafeMutableAddress {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  var next: Q2Node? {
    get             { return Q2Node(storage: nptr.load(.relaxed)) }
    nonmutating set { nptr.store(newValue?.storage, .relaxed) }
  }

  private var data: UnsafeMutablePointer<Element> {
    return (storage+dataOffset).assumingMemoryBound(to: Element.self)
  }

  func initialize(to element: Element)
  {
    nptr.store(nil, .relaxed)
    data.initialize(to: element)
  }

  func deinitialize()
  {
    data.deinitialize(count: 1)
  }

  func move() -> Element
  {
    return data.move()
  }
}
