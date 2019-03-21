//
//  fastqueue-spsc-lockfree.swift
//  QQ
//
//  Created by Guillaume Lessard
//  Copyright (c) 2018 Guillaume Lessard. All rights reserved.
//

/// Multiple-Producer, Single-Consumer, Lock-Free Queue
///
/// Adapted from Dmitry Vyukov's unbounded SPSC queue,
/// http://www.1024cores.net/home/lock-free-algorithms/queues/unbounded-spsc-queue
///
/// This algorithm is wait-free on both the producer and consumer paths
/// (modulo memory allocation and deallocation issues.)
/// Calls to enqueue() must be serialized in some way (single producer.)
/// Calls to dequeue() must be serialized in some way (single consumer.)

import CAtomics

final public class SPSCFastQueue<T>: QueueType
{
  public typealias Element = T
  private typealias Node = SPSCNode<T>

  private var hptr: AtomicPaddedMutableRawPointer
  private var head: Node {
    get { return Node(storage: hptr.load(.acquire)) }
    set { hptr.store(newValue.storage, .release) }
  }
  private var tail: Node
  private var oldest: Node
  private var headCopy: Node

  public init()
  { // set up an initial dummy node
    tail = Node.dummy
    hptr = AtomicPaddedMutableRawPointer(tail.storage)
    oldest = tail
    headCopy = tail
    assert(tail == head)
  }

  deinit {
    // empty the queue
    let head = self.head
    var next = head.next
    while let node = next
    {
      next = node.next
      node.deinitialize()
      node.deallocate()
    }
    head.next = nil

    next = oldest
    while let node = next
    {
      next = node.next
      node.deallocate()
    }
  }

  public var isEmpty: Bool { return head == tail }

  public var count: Int {
    var i = 0
    // only count as far as the current tail
    let tail = self.tail
    var next = self.head as Optional
    while let node = next, node != tail
    { // Iterate along the linked nodes while counting
      next = node.next
      i += 1
    }
    return i
  }

  private func node(with element: T) -> Node
  {
    if oldest != headCopy
    {
      let node = oldest
      guard let nextOldest = node.nptr.load(.relaxed) else { fatalError() }
      oldest = Node(storage: nextOldest)
      node.initialize(to: element)
      return node
    }
    else
    {
      headCopy = self.head
      if oldest != headCopy
      {
        let node = oldest
        guard let nextOldest = node.nptr.load(.relaxed) else { fatalError() }
        oldest = Node(storage: nextOldest)
        node.initialize(to: element)
        return node
      }
    }

    return Node(initializedWith: element)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    self.tail.next = node
    self.tail = node
  }

  public func dequeue() -> T?
  { // read the head (dummy) node and try to read the first real node
    let head = self.head
    let next = head.next
    guard let node = next else { return nil }

    // get the element and clear its storage in the node
    let element = node.move()
    // node is now a dummy node and points ot the first real node;
    // make self.head point to it for the next call to dequeue()
    self.head = node
    // the previous head node is now ready for reuse
    return element
  }
}

private let nextOffset = 0

private struct SPSCNode<Element>: OSAtomicNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  private var dataOffset: Int {
    return max(MemoryLayout<AtomicOptionalMutableRawPointer>.stride, MemoryLayout<Element>.alignment)
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
    let alignment = max(MemoryLayout<AtomicOptionalMutableRawPointer>.alignment, MemoryLayout<Element>.alignment)
    let offset = max(MemoryLayout<AtomicOptionalMutableRawPointer>.stride, MemoryLayout<Element>.alignment)
    let size = offset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+nextOffset).bindMemory(to: AtomicOptionalMutableRawPointer.self, capacity: 1)
    nptr = AtomicOptionalMutableRawPointer(nil)
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1)
  }

  static var dummy: SPSCNode { return SPSCNode() }

  init(initializedWith element: Element)
  {
    self.init()
    data.initialize(to: element)
  }

  func deallocate()
  {
    storage.deallocate()
  }

  var nptr: AtomicOptionalMutableRawPointer {
    unsafeAddress {
      return UnsafeRawPointer(storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
    nonmutating unsafeMutableAddress {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  var next: SPSCNode? {
    get             { return SPSCNode(storage: nptr.load(.acquire)) }
    nonmutating set { nptr.store(newValue?.storage, .release) }
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