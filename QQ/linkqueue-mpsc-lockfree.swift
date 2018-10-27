//
//  linkqueue-mpsc-lockfree.swift
//  QQ
//
//  Created by Guillaume Lessard
//  Copyright (c) 2018 Guillaume Lessard. All rights reserved.
//

/// Multiple-Producer, Single-Consumer, Lock-Free Queue
///
/// Adapted from Dmitry Vyukov's non-intrusive MPSC queue,
/// http://www.1024cores.net/home/lock-free-algorithms/queues/non-intrusive-mpsc-node-based-queue
/// which is itself a variant of a concurrent queue proposed by John M. Mellor-Crummey in
/// https://www.cs.rice.edu/~johnmc/papers/cqueues-mellor-crummey-TR229-1987-abstract.html
/// with the addition of Michael & Scott's dummy node insight from
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// (see also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html)
///
/// This algorithm is wait-free for the Producer path, and lock-free for the Consumer path.
/// Calls to enqueue() can be made from multiple simultaneous threads (multiple producers.)
/// Calls to dequeue() must be serialized in some way (single consumer.)

import CAtomics

final public class MPSCLinkQueue<T>: QueueType
{
  public typealias Element = T

  private var head = AtomicNonNullMutableRawPointer()
  private var tail = AtomicNonNullMutableRawPointer()

  public init()
  { // set up an initial dummy node
    let node = Node<T>()
    head.initialize(node: node)
    tail.initialize(node: node)
  }

  deinit {
    // empty the queue
    var node: Node<T>
    while true
    {
      node = head.loadNode(order: .acquire)
      defer { node.deallocate() }

      guard let next = node.loadNextNode(order: .acquire)
        else { break }

      head.store(node: next, order: .release)
    }
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

    // simultaneous producers synchronize with each other here
    let previousTail = self.tail.swap(node: node, order: .acqrel)

    /**
     If a producer thread is interrupted here (between the swap above and the store below),
     then the consumer can find itself encountering a head node which does not now its
     next node, even though the queue is not empty. This prevents the consumer side of
     the algorithm from being wait-free.
    */

    // publish the new node to the consumer here
    previousTail.storeNextNode(node, order: .release)
  }

  public func dequeue() -> T?
  { // read the head (dummy) node and try to read the first real node
    let head: Node<T>  = self.head.loadNode(order: .acquire)
    var next: Node<T>? = head.loadNextNode(order: .acquire)

    if next == nil
    { // check whether the queue is actually empty
      if tail.loadNode(order: .relaxed) == head
      { // the queue is empty
        return nil
      }

      // the queue isn't empty, but a producer hasn't finished enqueuing yet.
      var c: UInt8 = 0
      repeat { // wait for next to arrive
        c = c&+1
        if (c&0xe0) != 0
        { // we've spun enough; time to sleep.
          sched_yield()
        }

        next = head.loadNextNode(order: .acquire)
      } while next == nil
    }

    guard let node = next else { fatalError(#function) }

    // get the element and clear its storage in the node
    let element = node.move()
    // node is now a dummy node and points ot the first real node;
    // make self.head point to it for the next call to dequeue()
    self.head.store(node: node, order: .release)
    // we can now dispose of the previous head node
    head.deallocate()
    return element
  }
}

// Extensions used to deal with the queue's head and tail pointers

extension AtomicNonNullMutableRawPointer
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

  mutating fileprivate func swap<T>(node: Node<T>, order: MemoryOrder = .acqrel) -> Node<T>
  {
    let pointer = self.swap(node.storage, order)
    return Node(storage: pointer)
  }
}

private let nextOffset = 0
private let dataOffset = nextOffset + MemoryLayout<AtomicMutableRawPointer>.stride

private struct Node<Element>: OSAtomicNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  private init()
  {
    let size = dataOffset + MemoryLayout<Element?>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 16)
    (storage+nextOffset).bindMemory(to: AtomicMutableRawPointer.self, capacity: 1)
    (storage+nextOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self).pointee = AtomicMutableRawPointer()
    (storage+nextOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self).pointee.initialize(nil)
    (storage+dataOffset).bindMemory(to: (Element?).self, capacity: 1)
  }

  init(none: Element? = nil)
  {
    self.init()
    (storage+dataOffset).assumingMemoryBound(to: (Element?).self).initialize(to: nil)
  }

  init(_ element: Element)
  {
    self.init()
    (storage+dataOffset).assumingMemoryBound(to: (Element?).self).initialize(to: element)
  }

  func deallocate()
  {
    (storage+dataOffset).assumingMemoryBound(to: (Element?).self).deinitialize(count: 1)
    storage.deallocate()
  }

  private var next: UnsafeMutablePointer<AtomicMutableRawPointer> {
    get {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self)
    }
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
    let element = (storage+dataOffset).assumingMemoryBound(to: (Element?).self).pointee
    (storage+dataOffset).assumingMemoryBound(to: (Element?).self).pointee = nil
    return element
  }
}
