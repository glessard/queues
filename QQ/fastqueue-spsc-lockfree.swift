//
//  linkqueue-spsc-lockfree.swift
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
/// Calls to enqueue() must be serialized in some way (single producer.)
/// Calls to dequeue() must be serialized in some way (single consumer.)

import CAtomics

final public class SPSCFastQueue<T>: QueueType
{
  public typealias Element = T

  // these don't actually need to be atomic, but they're better off with the padding
  private var head: AtomicCacheLineAlignedMutableRawPointer
  private var tail: AtomicCacheLineAlignedMutableRawPointer
  private var oldest: UnsafeMutableRawPointer
  private var recentHead: UnsafeMutableRawPointer

  public init()
  { // set up an initial dummy node
    let node = Node<T>()
    head = AtomicCacheLineAlignedMutableRawPointer(node.storage)
    tail = AtomicCacheLineAlignedMutableRawPointer(node.storage)
    oldest = UnsafeMutableRawPointer(node.storage)
    recentHead = UnsafeMutableRawPointer(node.storage)
  }

  deinit {
    // empty the queue
    let head: Node<T> = Node(storage: oldest)
    var next = head.loadNextNode(order: .acquire)
    while let node = next
    {
      next = node.loadNextNode(order: .acquire)
      node.deallocate()
    }
    head.deallocate()
  }

  public var isEmpty: Bool { return head.load(.relaxed) == tail.load(.relaxed) }

  public var count: Int {
    var i = 0
    // only count as far as the current tail
    let tail: Node<T>  = self.tail.loadNode(order: .acquire)
    var next: Node<T>? = self.head.loadNode(order: .acquire)
    while let node = next, node != tail
    { // Iterate along the linked nodes while counting
      repeat {
        // if node was not yet tail, then a `nil` next pointer
        // does not mean we are done counting.
        next = node.loadNextNode(order: .acquire)
      } while next == nil
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = Node(newElement)

    tail.loadNode(order: .relaxed).storeNextNode(node, order: .release)
    tail.store(node: node, order: .relaxed)
  }

  public func dequeue() -> T?
  { // read the head (dummy) node and try to read the first real node
    let head: Node<T>  = self.head.loadNode(order: .relaxed)

    guard let node: Node<T> = head.loadNextNode(order: .acquire)
      else { return nil }

    // get the element and clear its storage in the node
    let element = node.move()
    // node is now a dummy node and points ot the first real node;
    // make self.head point to it for the next call to dequeue()
    self.head.store(node: node, order: .relaxed)

    // we can now dispose of the previous head node
    head.deallocate()
    return element
  }
}

// Extensions used to deal with the queue's head and tail pointers

extension AtomicCacheLineAlignedMutableRawPointer
{
  mutating fileprivate func initialize<T>(node: Node<T>)
  {
    self.initialize(node.storage)
  }

  mutating fileprivate func loadNode<T>(order: LoadMemoryOrder) -> Node<T>
  {
    return Node(storage: self.load(order))
  }

  mutating fileprivate func store<T>(node: Node<T>, order: StoreMemoryOrder = .release)
  {
    self.store(node.storage, order)
  }
}

private struct Node<Element>: OSAtomicNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  private var nextOffset: Int { return 0 }
  private var dataOffset: Int {
    return (MemoryLayout<AtomicOptionalMutableRawPointer>.alignment > MemoryLayout<Element?>.alignment) ?
      MemoryLayout<AtomicOptionalMutableRawPointer>.stride : MemoryLayout<Element?>.stride
  }

  var next: UnsafeMutablePointer<AtomicOptionalMutableRawPointer> {
    return (storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
  }

  var data: UnsafeMutablePointer<Element?> {
    return (storage+dataOffset).assumingMemoryBound(to: (Element?).self)
  }

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  private init(private: Void = ())
  {
    let alignment = max(MemoryLayout<AtomicOptionalMutableRawPointer>.alignment, MemoryLayout<Element?>.alignment)
    let offset = (MemoryLayout<AtomicOptionalMutableRawPointer>.alignment > MemoryLayout<Element?>.alignment) ?
                  MemoryLayout<AtomicOptionalMutableRawPointer>.stride : MemoryLayout<Element?>.stride
    let size = offset + MemoryLayout<Element?>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+nextOffset).bindMemory(to: AtomicOptionalMutableRawPointer.self, capacity: 1)
    (storage+dataOffset).bindMemory(to: (Element?).self, capacity: 1)
  }

  init()
  {
    self.init(private: ())
    next.pointee = AtomicOptionalMutableRawPointer()
    next.pointee.initialize(nil)
    data.initialize(to: nil)
  }

  init(_ element: Element)
  {
    self.init(private: ())
    next.pointee = AtomicOptionalMutableRawPointer()
    next.pointee.initialize(nil)
    data.initialize(to: element)
  }

  func deallocate()
  {
    data.deinitialize(count: 1)
    storage.deallocate()
  }

  func loadNextNode(order: LoadMemoryOrder = .acquire) -> Node?
  {
    guard let storage = next.pointee.load(order) else { return nil }
    return Node(storage: storage)
  }

  func storeNextNode(_ node: Node, order: StoreMemoryOrder = .release)
  {
    next.pointee.store(node.storage, order)
  }

  func move() -> Element?
  {
    let element = data.move()
    data.initialize(to: nil)
    return element
  }
}
