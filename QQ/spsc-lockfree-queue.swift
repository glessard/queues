//
//  spsc-lockfree-queue.swift
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

final public class SPSCLockFreeQueue<T>: QueueType
{
  public typealias Element = T
  private typealias Node = SPSCNode<T>

  private var hptr: UnsafeMutableRawPointer
  private var head: Node {
    get { return Node(storage: hptr) }
    set { hptr = newValue.storage }
  }
  private var tail: Node

  public init()
  { // set up an initial dummy node
    tail = Node.dummy
    hptr = UnsafeMutableRawPointer(tail.storage)
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
    head.deallocate()
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

  public func enqueue(_ newElement: T)
  {
    let node = Node(initializedWith: newElement)

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
    // we can now dispose of the previous head node
    head.deallocate()
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

  private var nptr: UnsafeMutablePointer<AtomicOptionalMutableRawPointer> {
    get {
      return UnsafeMutableRawPointer(storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  var next: SPSCNode? {
    get             { return SPSCNode(storage: CAtomicsLoad(nptr, .acquire)) }
    nonmutating set { CAtomicsStore(nptr, newValue?.storage, .release) }
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
