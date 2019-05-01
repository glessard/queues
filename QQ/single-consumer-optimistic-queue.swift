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
  private let tail = UnsafeMutablePointer<AtomicTaggedMutableRawPointer>.allocate(capacity: 1)

  public init()
  {
    let node = Node.dummy
    head = TaggedMutableRawPointer(node.storage, tag: 1)
    CAtomicsInitialize(tail, head)
  }

  deinit
  {
    // empty the queue
    // delete from tail to head because the `prev` pointer is most reliable
    let head = Node(storage: self.head.ptr)
    var last = Node(storage: CAtomicsLoad(tail, .acquire).ptr)
    while last != head
    {
      let prev = Node(storage: last.prev.ptr)
      last.deinitialize()
      last.deallocate()
      last = prev
    }
    head.deallocate()
    tail.deallocate()
  }

  public var isEmpty: Bool { return head.ptr == CAtomicsLoad(tail, .relaxed).ptr }

  public var count: Int {
    var i = 0
    // count from the current tail until head
    var current = CAtomicsLoad(tail, .acquire)
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

    var oldTail = CAtomicsLoad(tail, .acquire)
    var newTail: TaggedMutableRawPointer
    repeat {
      node.prev = oldTail.incremented()
      newTail =   oldTail.incremented(with: node.storage)
    } while !CAtomicsCompareAndExchange(tail, &oldTail, newTail, .weak, .release, .relaxed)

    // success, update the old tail's next link
    let oldTailNext = TaggedOptionalMutableRawPointer(node.storage, tag: oldTail.tag)
    CAtomicsStore(Node(storage: oldTail.ptr).next, oldTailNext, .release)
  }

  public func dequeue() -> T?
  {
    let head = self.head
    var next = CAtomicsLoad(Node(storage: head.ptr).next, .acquire)

    if next == nullNode || (next.tag != head.tag)
    { // the queue might actually be empty
      let tail = CAtomicsLoad(self.tail, .acquire)
      if head == tail { return nil }

      fixlist(tail: tail, head: head)
      next = CAtomicsLoad(Node(storage: head.ptr).next, .acquire)
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
      CAtomicsStore(currentPrev.next, updated, .relaxed)
      current = TaggedMutableRawPointer(currentPrev.storage, tag: tag)
    }
  }
}

private let nullNode = TaggedOptionalMutableRawPointer(nil, tag: 0)

private struct NodePrefix
{
  var prev: TaggedMutableRawPointer
  var next: AtomicTaggedOptionalMutableRawPointer
}

private let prevOffset = MemoryLayout.offset(of: \NodePrefix.prev)!
private let nextOffset = MemoryLayout.offset(of: \NodePrefix.next)!

private struct OptimisticNode<Element>: Equatable
{
  let storage: UnsafeMutableRawPointer

  private var dataOffset: Int {
    let dataMask = MemoryLayout<Element>.alignment - 1
    return (MemoryLayout<NodePrefix>.size + dataMask) & ~dataMask
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
    let size = MemoryLayout<NodePrefix>.size + MemoryLayout<Element>.size
    let alignment  = MemoryLayout<NodePrefix>.alignment
    assert(alignment == 16)
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+prevOffset).bindMemory(to: TaggedMutableRawPointer.self, capacity: 1)
    prev = TaggedMutableRawPointer()
    (storage+nextOffset).bindMemory(to: AtomicTaggedOptionalMutableRawPointer.self, capacity: 1)
    CAtomicsInitialize(next, nullNode)
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

  var next: UnsafeMutablePointer<AtomicTaggedOptionalMutableRawPointer> {
    @inlinable get {
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
