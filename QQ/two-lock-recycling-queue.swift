//
//  two-lock-recycling-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import struct Darwin.os.lock.os_unfair_lock_s
import func   Darwin.os.lock.os_unfair_lock_lock
import func   Darwin.os.lock.os_unfair_lock_unlock

import CAtomics

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

  private let storage = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<TwoLockQueueData>.size,
                                                         alignment: MemoryLayout<TwoLockQueueData>.alignment)

  private var hptr: UnsafeMutablePointer<AtomicMutableRawPointer> {
    return (storage + hptrOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self)
  }
  private var head: Node {
    get { return Node(storage: CAtomicsLoad(hptr, .relaxed)) }
    set { CAtomicsStore(hptr, newValue.storage, .relaxed) }
  }
  private var tail: Node

  private var hlock: UnsafeMutablePointer<os_unfair_lock_s> {
    return (storage + hlockOffset).assumingMemoryBound(to: os_unfair_lock_s.self)
  }
  private var tlock: UnsafeMutablePointer<os_unfair_lock_s> {
    return (storage + tlockOffset).assumingMemoryBound(to: os_unfair_lock_s.self)
  }

  private var pool: UnsafeMutablePointer<AtomicTaggedMutableRawPointer> {
    return (storage + poolOffset).assumingMemoryBound(to: AtomicTaggedMutableRawPointer.self)
  }

  public init()
  { // set up an initial dummy node
    tail = Node.dummy
    (storage+hlockOffset).bindMemory(to: os_unfair_lock_s.self, capacity: 1)
    hlock.pointee = os_unfair_lock_s()
    (storage+tlockOffset).bindMemory(to: os_unfair_lock_s.self, capacity: 1)
    tlock.pointee = os_unfair_lock_s()
    (storage+hptrOffset).bindMemory(to: AtomicMutableRawPointer.self, capacity: 1)
    CAtomicsInitialize(hptr, tail.storage)
    (storage+poolOffset).bindMemory(to: AtomicTaggedMutableRawPointer.self, capacity: 1)
    CAtomicsInitialize(pool, TaggedMutableRawPointer(tail.storage, tag: 1))
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

    next = Node(storage: CAtomicsLoad(pool, .acquire).ptr)
    while let node = next
    {
      next = node.next
      node.deallocate()
    }
    storage.deallocate()
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
    var pool = CAtomicsLoad(self.pool, .acquire)
    while pool.ptr != CAtomicsLoad(hptr, .relaxed)
    {
      let node = Node(storage: pool.ptr)
      if let n = node.next
      {
        let next = pool.incremented(with: n.storage)
        if CAtomicsCompareAndExchange(self.pool, &pool, next, .strong, .acqrel, .acquire)
        {
          node.initialize(to: element)
          return node
        }
      }
      else
      { // this can happen if another thread has succeeded
        // in advancing the pool pointer and has already
        // started initializing the node for enqueueing
        pool = CAtomicsLoad(self.pool, .acquire)
      }
    }

    return Node(initializedWith: element)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    os_unfair_lock_lock(tlock)
    tail.next = node
    tail = node
    os_unfair_lock_unlock(tlock)
  }

  public func dequeue() -> T?
  {
    os_unfair_lock_lock(hlock)
    if let next = head.next
    {
      head = next
      let element = next.move()
      os_unfair_lock_unlock(hlock)

      return element
    }

    // queue is empty
    os_unfair_lock_unlock(hlock)
    return nil
  }
}

private struct TwoLockQueueData
{
  let hptr: AtomicMutableRawPointer
  let pool: AtomicTaggedMutableRawPointer

  let hlock: os_unfair_lock_s
  let tlock: os_unfair_lock_s
}

private let hptrOffset =  MemoryLayout.offset(of: \TwoLockQueueData.hptr)!
private let poolOffset =  MemoryLayout.offset(of: \TwoLockQueueData.pool)!
private let hlockOffset = MemoryLayout.offset(of: \TwoLockQueueData.hlock)!
private let tlockOffset = MemoryLayout.offset(of: \TwoLockQueueData.tlock)!

private let nextOffset = 0

private struct Q2Node<Element>: OSAtomicNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  private var dataOffset: Int {
    return max(MemoryLayout<AtomicMutableRawPointer>.stride, MemoryLayout<Element>.alignment)
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
    CAtomicsInitialize(nptr, nil)
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

  private var nptr: UnsafeMutablePointer<AtomicOptionalMutableRawPointer> {
    get {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  var next: Q2Node? {
    get             { return Q2Node(storage: CAtomicsLoad(nptr, .relaxed)) }
    nonmutating set { CAtomicsStore(nptr, newValue?.storage, .relaxed) }
  }

  private var data: UnsafeMutablePointer<Element> {
    return (storage+dataOffset).assumingMemoryBound(to: Element.self)
  }

  func initialize(to element: Element)
  {
    CAtomicsStore(nptr, nil, .relaxed)
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
