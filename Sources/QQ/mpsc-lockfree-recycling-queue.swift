//
//  mpsc-lockfree-queue.swift
//  QQ
//
//  Created by Guillaume Lessard
//  Copyright (c) 2018 Guillaume Lessard. All rights reserved.
//

/// Multiple-Producer, Single-Consumer, (mostly) Lock-Free Queue
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
/// This algorithm is wait-free for the Producer path.
/// Calls to enqueue() can be made from multiple simultaneous threads (multiple producers.)
/// The consumer path is generally lock-free, though a producer that is delayed
/// at a crucial point can lead to the consumer thread being temporarily suspended.
/// Calls to dequeue() must be serialized in some way (single consumer.)

import CAtomics

final public class MPSCLockFreeRecyclingQueue<T>: QueueType
{
  public typealias Element = T
  private typealias Node = MPSCNode<T>

  private let storage = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<MPSCQueueData>.size,
                                                         alignment: MemoryLayout<MPSCQueueData>.alignment)

  private var hptr: UnsafeMutablePointer<AtomicMutableRawPointer> {
    return (storage+headOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self )
  }
  private var head: Node {
    get { return Node(storage: CAtomicsLoad(hptr, .acquire)) }
    set { CAtomicsStore(hptr, newValue.storage, .release) }
  }

  private var tptr: UnsafeMutablePointer<AtomicMutableRawPointer> {
    return (storage+tailOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self )
  }
  private var tail: Node {
    get { return Node(storage: CAtomicsLoad(tptr, .acquire)) }
    set { CAtomicsStore(tptr, newValue.storage, .release) }
  }

  private var pptr: UnsafeMutablePointer<AtomicTaggedMutableRawPointer> {
    return (storage+poolOffset).assumingMemoryBound(to: AtomicTaggedMutableRawPointer.self )
  }
  private var pool: TaggedMutableRawPointer {
    get { return CAtomicsLoad(pptr, .acquire) }
    set { CAtomicsStore(pptr, newValue, .release) }
  }

  public init()
  { // set up an initial dummy node
    let dummy = Node.dummy
    (storage+headOffset).bindMemory(to: AtomicMutableRawPointer.self, capacity: 1)
    CAtomicsInitialize(hptr, dummy.storage)
    (storage+tailOffset).bindMemory(to: AtomicMutableRawPointer.self, capacity: 1)
    CAtomicsInitialize(tptr, dummy.storage)
    (storage+poolOffset).bindMemory(to: AtomicTaggedMutableRawPointer.self, capacity: 2)
    CAtomicsInitialize(pptr, TaggedMutableRawPointer(dummy.storage, tag: 1))
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

    next = Node(storage: pool.ptr)
    while let node = next
    {
      next = node.next
      node.deallocate()
    }
    storage.deallocate()
  }

  public var isEmpty: Bool { return CAtomicsLoad(hptr, .relaxed) == CAtomicsLoad(tptr, .relaxed) }

  public var count: Int {
    var i = 0
    // only count as far as the current tail
    let tail = self.tail
    var next = self.head as Optional
    while let node = next, node != tail
    { // Iterate along the linked nodes while counting
      repeat {
        // if node was not yet tail, then a `nil` next pointer
        // does not mean we are done counting.
        next = node.next
      } while next == nil
      i += 1
    }
    return i
  }

  private func node(with element: T) -> Node
  {
    var pool = self.pool
    while pool.ptr != CAtomicsLoad(hptr, .relaxed)
    {
      let node = Node(storage: pool.ptr)
      if let n = node.next
      {
        let next = pool.incremented(with: n.storage)
        if CAtomicsCompareAndExchangeWeak(pptr, &pool, next, .acqrel, .acquire)
        {
          node.initialize(to: element)
          return node
        }
      }
      else
      { // this can happen if another thread has succeeded
        // in advancing the pool pointer and has already
        // started initializing the node for enqueueing
        pool = self.pool
      }
    }

    return Node(initializedWith: element)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    // simultaneous producers synchronize with each other here
    let previousTailPointer = CAtomicsExchange(tptr, node.storage, .acqrel)
    let previousTail = Node(storage: previousTailPointer)

    /**
     If a producer thread is interrupted here (between the swap above and the store below),
     then the consumer can find itself encountering a head node which does not know its
     next node, even though the queue is not empty. This prevents the consumer side of
     the algorithm from being wait-free.
    */

    // publish the new node to the consumer here
    previousTail.next = node
  }

  public func dequeue() -> T?
  { // read the head (dummy) node and try to read the first real node
    let head = self.head
    var next = head.next

    if next == nil
    { // check whether the queue is actually empty
      if head.storage == CAtomicsLoad(tptr, .relaxed)
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

        next = head.next
      } while next == nil
    }

    guard let node = next else { fatalError(#function) }

    // get the element and clear its storage in the node
    let element = node.move()
    // node is now a dummy node and points to the first real node;
    // make self.head point to it for the next call to dequeue()
    self.head = node
    return element
  }
}

private struct MPSCQueueData
{
  var head: AtomicMutableRawPointer
  var tail: AtomicMutableRawPointer
  var pool: AtomicTaggedMutableRawPointer
}

private let headOffset = MemoryLayout.offset(of: \MPSCQueueData.head)!
private let tailOffset = MemoryLayout.offset(of: \MPSCQueueData.tail)!
private let poolOffset = MemoryLayout.offset(of: \MPSCQueueData.pool)!

private struct NodePrefix
{
  var next: AtomicOptionalMutableRawPointer
}

private let nextOffset = MemoryLayout.offset(of: \NodePrefix.next)!

private struct MPSCNode<Element>: OSAtomicNode, Equatable
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
    let alignment  = max(MemoryLayout<NodePrefix>.alignment, MemoryLayout<Element>.alignment)
    let dataMask   = MemoryLayout<Element>.alignment - 1
    let dataOffset = (MemoryLayout<NodePrefix>.size + dataMask) & ~dataMask
    let size = dataOffset + MemoryLayout<Element>.size
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+nextOffset).bindMemory(to: AtomicOptionalMutableRawPointer.self, capacity: 1)
    CAtomicsInitialize(nptr, nil)
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

  private var nptr: UnsafeMutablePointer<AtomicOptionalMutableRawPointer> {
    get {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  var next: MPSCNode? {
    get             { return MPSCNode(storage: CAtomicsLoad(nptr, .acquire)) }
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
