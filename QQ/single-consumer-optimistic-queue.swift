//
//  single-consumer-optimistic-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import CAtomics

/// Multiple-Producer, Single-Consumer, (mostly) Lock-Free Queue
///
/// Adapted from the Optimistic Lock-free queue algorithm by Edya Ladan-Mozes and Nir Shavit,
/// "An optimistic approach to lock-free FIFO queues",
/// Distributed Computing (2008) 20:323-341; DOI 10.1007/s00446-007-0050-0
///
/// See also:
/// Proceedings of the 18th International Conference on Distributed Computing (DISC) 2004
/// http://people.csail.mit.edu/edya/publications/OptimisticFIFOQueue-DISC2004.pdf
///
/// This algorithm is lock-free for both the Producer and Consumer paths.
/// Calls to enqueue() can be made from multiple simultaneous threads (multiple producers.)
/// Calls to dequeue() must be serialized in some way (single consumer.)
/// The serialization of the consumer enables the algorithm to work properly with
/// ARC-enabled memory and avoids other memory-related issues by ensuring that
/// no concurrency exists on that path.

final public class SingleConsumerOptimisticQueue<T>: QueueType
{
  public typealias Element = T
  private typealias Node = OptimisticNode<T>

  private var head: TaggedMutableRawPointer
  private var tail: AtomicTaggedMutableRawPointer

  public init()
  {
    let node = Node.dummy
    head = TaggedMutableRawPointer(node.storage, tag: 1)
    tail = AtomicTaggedMutableRawPointer(head)
  }

  deinit
  {
    // empty the queue
    // delete from tail to head because the `prev` pointer is most reliable
    let head = Node(storage: self.head.ptr)
    var last = Node(storage: self.tail.load(.acquire).ptr)
    while last != head
    {
      let prev = Node(storage: last.prev.ptr)
      last.deinitialize()
      last.deallocate()
      last = prev
    }
    head.deallocate()
  }

  public var isEmpty: Bool { return head.ptr == tail.load(.relaxed).ptr }

  public var count: Int {
    var i = 0
    // count from the current tail until head
    var current = tail.load(.acquire)
    let head =    self.head
    while current.ptr != head.ptr
    { // Iterate along the linked nodes while counting
      current = Node(storage: current.ptr).prev
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = Node(initializedWith: newElement)

    var oldTail = self.tail.load(.acquire)
    var newTail: TaggedMutableRawPointer
    repeat {
      node.prev = oldTail.incremented()
      newTail =   oldTail.incremented(with: node.storage)
    } while !self.tail.loadCAS(&oldTail, newTail, .weak, .release, .relaxed)

    // success, update the old tail's next link
    let oldTailNext = TaggedOptionalMutableRawPointer(node.storage, tag: oldTail.tag)
    Node(storage: oldTail.ptr).next.store(oldTailNext, .relaxed)
  }

  public func dequeue() -> T?
  {
    let head = self.head
    var next = Node(storage: head.ptr).next.load(.acquire)

    if next == nullNode || (next.tag != head.tag)
    { // the queue might actually be empty
      let tail = self.tail.load(.acquire)
      if head == tail { return nil }

      fixlist(tail: tail, head: head)
      next = Node(storage: head.ptr).next.load(.acquire)
    }

    guard let node = Node(storage: next.ptr) else { fatalError(#function) }

    self.head = head.incremented(with: node.storage)
    Node(storage: head.ptr).deallocate()
    return node.move()
  }

  private func fixlist(tail oldtail: TaggedMutableRawPointer, head oldhead: TaggedMutableRawPointer)
  { // should only be called as part of the (serialized) dequeue() path
    var current = oldtail
    while current != oldhead
    {
      let currentNode = Node(storage: current.ptr)
      let currentPrev = Node(storage: currentNode.prev.ptr)

      let tag = current.tag &- 1
      let updated = TaggedOptionalMutableRawPointer(current.ptr, tag: tag)
      currentPrev.next.store(updated, .relaxed)
      current = TaggedMutableRawPointer(currentPrev.storage, tag: tag)
    }
  }
}

private let prevOffset = 0
private let nextMask   = MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.alignment - 1
private let nextOffset = (prevOffset + MemoryLayout<TaggedMutableRawPointer>.stride + nextMask) & ~nextMask

private let nullNode = TaggedOptionalMutableRawPointer(nil, tag: 0)

private struct OptimisticNode<Element>: OSAtomicNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  private var dataOffset: Int {
    let dataMask = MemoryLayout<Element>.alignment - 1
    return (nextOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride + dataMask) & ~dataMask
  }

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  init?(storage: UnsafeMutableRawPointer?)
  {
    guard let storage = storage else { return nil }
    self.storage = storage
  }

  private init()
  {
    let alignment  = MemoryLayout<TaggedMutableRawPointer>.alignment
    let dataMask   = MemoryLayout<Element>.alignment - 1
    let dataOffset = (nextOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride + dataMask) & ~dataMask
    let size = dataOffset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+prevOffset).bindMemory(to: TaggedMutableRawPointer.self, capacity: 1)
    prev = TaggedMutableRawPointer()
    (storage+nextOffset).bindMemory(to: AtomicTaggedOptionalMutableRawPointer.self, capacity: 1)
    next = AtomicTaggedOptionalMutableRawPointer(nullNode)
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1)
  }

  static var dummy: OptimisticNode { return OptimisticNode() }

  init(initializedWith element: Element)
  {
    self.init()
    data.initialize(to: element)
  }

  func deallocate()
  {
    storage.deallocate()
  }

  var prev: TaggedMutableRawPointer {
    @inlinable unsafeAddress {
      return UnsafeRawPointer(storage+prevOffset).assumingMemoryBound(to: TaggedMutableRawPointer.self)
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+prevOffset).assumingMemoryBound(to: TaggedMutableRawPointer.self)
    }
  }

  var next: AtomicTaggedOptionalMutableRawPointer {
    @inlinable unsafeAddress {
      return UnsafeRawPointer(storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
    }
  }

  private var data: UnsafeMutablePointer<Element> {
    return (storage+dataOffset).assumingMemoryBound(to: Element.self)
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
