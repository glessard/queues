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
/// with the addition of J.D. Valois's dummy node insight from "Implementing Lock-Free Queues",
/// In Seventh International Conference on Parallel and Distributed Computing Systems, Oct. 1994
/// (see also: Michael & Scott algorithm from their PODC96 paper, at
/// http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html)
///
/// This algorithm is wait-free for the Producer path, and lock-free for the Consumer path.
/// Calls to enqueue() can be made from multiple simultaneous threads (multiple producers.)
/// Calls to dequeue() must be serialized in some way (single consumer.)

import CAtomics

final public class MPSCLinkQueue<T>: QueueType
{
  public typealias Element = T
  private typealias Node = MPSCNode<T>

  private var head: UnsafeMutableRawPointer
  private var tail: AtomicCacheLineAlignedMutableRawPointer

  public init()
  { // set up an initial dummy node
    let node = Node.dummy
    head = node.storage
    tail = AtomicCacheLineAlignedMutableRawPointer(head)
  }

  deinit {
    // empty the queue
    let head = Node(storage: self.head)
    var next = Node(storage: head.next.load(.acquire))
    while let node = next
    {
      next = Node(storage: node.next.load(.acquire))
      node.deinitialize()
      node.deallocate()
    }
    head.deallocate()
  }

  public var isEmpty: Bool { return head == tail.load(.relaxed) }

  public var count: Int {
    var i = 0
    // only count as far as the current tail
    let tail = Node(storage: self.tail.load(.acquire))
    var next = Node(storage: self.head as Optional)
    while let node = next, node != tail
    { // Iterate along the linked nodes while counting
      repeat {
        // if node was not yet tail, then a `nil` next pointer
        // does not mean we are done counting.
        next = Node(storage: node.next.load(.acquire))
      } while next == nil
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = Node(initializedWith: newElement)

    // simultaneous producers synchronize with each other here
    let previousTail = Node(storage: self.tail.swap(node.storage, .acqrel))

    /**
     If a producer thread is interrupted here (between the swap above and the store below),
     then the consumer can find itself encountering a head node which does not know its
     next node, even though the queue is not empty. This prevents the consumer side of
     the algorithm from being wait-free.
    */

    // publish the new node to the consumer here
    previousTail.next.store(node.storage, .release)
  }

  public func dequeue() -> T?
  { // read the head (dummy) node and try to read the first real node
    let head = Node(storage: self.head)
    var next = head.next.load(.acquire)

    if next == nil
    { // check whether the queue is actually empty
      if tail.load(.relaxed) == head.storage
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

        next = head.next.load(.acquire)
      } while next == nil
    }

    guard let node = Node(storage: next) else { fatalError(#function) }

    // get the element and clear its storage in the node
    let element = node.move()
    // node is now a dummy node and points to the first real node;
    // make self.head point to it for the next call to dequeue()
    self.head = node.storage
    // we can now dispose of the previous head node
    head.deallocate()
    return element
  }
}

private let nextOffset = 0

private struct MPSCNode<Element>: OSAtomicNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  private var dataOffset: Int {
    let a = MemoryLayout<Element>.alignment
    let d = (nextOffset + MemoryLayout<AtomicOptionalMutableRawPointer>.stride - a)/a
    return a*d+a
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
    let a = MemoryLayout<Element>.alignment
    let d = (nextOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride - a)/a
    let size = a*d+a + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+nextOffset).bindMemory(to: AtomicOptionalMutableRawPointer.self, capacity: 1)
    next = AtomicOptionalMutableRawPointer(nil)
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1)
  }

  static var dummy: MPSCNode { return MPSCNode() }

  init(initializedWith element: Element)
  {
    self.init()
    data.initialize(to: element)
  }

  func deallocate()
  {
    storage.deallocate()
  }

  var next: AtomicOptionalMutableRawPointer {
    @inlinable unsafeAddress {
      return UnsafeRawPointer(storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  private var data: UnsafeMutablePointer<Element> {
    return (storage+dataOffset).assumingMemoryBound(to: Element.self)
  }

  func initialize(to element: Element)
  {
    next.store(nil, .relaxed)
    data.initialize(to: element)
  }

  func deinitialize()
  {
    data.deinitialize(count: 1)
  }

  func read() -> Element?
  {
    return data.pointee
  }

  func move() -> Element
  {
    return data.move()
  }
}
