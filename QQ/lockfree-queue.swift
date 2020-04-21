//
//  lockfree-queue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import CAtomics

/// Lock-free queue (with node recycling)
///
/// Note that node recycling is necessary with this algorithm.
/// A non-recycling algorithm is possible by using hazard pointers,
/// or possibly by relying on ARC.
///
/// Lock-free queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html

final public class LockFreeQueue<T>: QueueType
{
  public typealias Element = T
  typealias Node = LockFreeNode

  let storage = UnsafeMutablePointer<AtomicTaggedMutableRawPointer>.allocate(capacity: 4)
  private var head: UnsafeMutablePointer<AtomicTaggedMutableRawPointer> { return storage+0 }
  private var tail: UnsafeMutablePointer<AtomicTaggedMutableRawPointer> { return storage+1 }
  private var poolhead: UnsafeMutablePointer<AtomicTaggedMutableRawPointer> { return storage+2 }
  private var pooltail: UnsafeMutablePointer<AtomicTaggedMutableRawPointer> { return storage+3 }

  public init()
  {
    let node = Node.dummy
    let tmrp = TaggedMutableRawPointer(node.storage, tag: 1)
    CAtomicsInitialize(head, tmrp)
    CAtomicsInitialize(tail, tmrp)
    CAtomicsInitialize(poolhead, tmrp)
    CAtomicsInitialize(pooltail, tmrp)
  }

  deinit
  {
    // empty the queue
    let head = Node(storage: CAtomicsLoad(self.head, .acquire).ptr)
    var next = Node(storage: CAtomicsLoad(head.next, .acquire).ptr)
    while let node = next
    {
      next = Node(storage: CAtomicsLoad(node.next, .acquire).ptr)
      if let pointer = CAtomicsExchange(node.data, nil, .acquire)?.assumingMemoryBound(to: T.self)
      {
        pointer.deinitialize(count: 1)
        pointer.deallocate()
      }
      node.deallocate()
    }
    CAtomicsStore(head.next, TaggedOptionalMutableRawPointer(nil, tag: 0), .release)

    next = Node(storage: CAtomicsLoad(poolhead, .acquire).ptr)
    while let node = next
    {
      next = Node(storage: CAtomicsLoad(node.next, .acquire).ptr)
      node.deallocate()
    }
    storage.deallocate()
  }

  public var isEmpty: Bool { return CAtomicsLoad(head, .relaxed).ptr == CAtomicsLoad(tail, .relaxed).ptr }

  public var count: Int {
    var i = 0
    let tail = Node(storage: CAtomicsLoad(self.tail, .relaxed).ptr)
    var next = CAtomicsLoad(Node(storage: CAtomicsLoad(self.head, .relaxed).ptr).next, .relaxed).ptr
    while let current = Node(storage: next)
    { // Iterate along the linked nodes while counting
      next = CAtomicsLoad(current.next, .relaxed).ptr
      i += 1
      if current == tail { break }
    }
    return i
  }

  private func node(with element: T) -> Node
  {
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    pointer.initialize(to: element)

    var pool = CAtomicsLoad(self.poolhead, .acquire)
    while pool.ptr != CAtomicsLoad(pooltail, .relaxed).ptr
    {
      let node = Node(storage: pool.ptr)
      if let n = CAtomicsLoad(node.next, .acquire).ptr
      {
        let next = pool.incremented(with: n)
        if CAtomicsCompareAndExchange(self.poolhead, &pool, next, .strong, .acqrel, .acquire)
        {
          node.initialize(to: pointer)
          return node
        }
      }
      else
      { // this can happen if another thread has succeeded
        // in advancing the pool pointer and has already
        // started initializing the node for enqueueing
        pool = CAtomicsLoad(self.poolhead, .acquire)
      }
    }

    return Node(initializedWith: pointer)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    while true
    {
      let tail = CAtomicsLoad(self.tail, .acquire)
      let tailNode = Node(storage: tail.ptr)

      let next = CAtomicsLoad(tailNode.next, .acquire)
      if let nextNode = Node(storage: next.ptr)
      { // tail wasn't pointing to the actual last node; try to fix it.
        let next = TaggedMutableRawPointer(nextNode.storage, tag: next.tag &+ 1)
        CAtomicsCompareAndExchange(self.tail, tail, next, .strong, .release)
      }
      else
      { // try to link the new node to the end of the list
        let baseNode = TaggedOptionalMutableRawPointer()
        let nextNode = next.incremented(with: node.storage)
        if CAtomicsCompareAndExchange(tailNode.next, baseNode, nextNode, .weak, .release)
        { // success. try to have tail point to the inserted node.
          let newTail = tail.incremented(with: node.storage)
          CAtomicsCompareAndExchange(self.tail, tail, newTail, .strong, .release)
          break
        }
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let head = CAtomicsLoad(self.head, .acquire)
      let tail = CAtomicsLoad(self.tail, .relaxed)
      let next = CAtomicsLoad(Node(storage: head.ptr).next, .acquire)

      if head == CAtomicsLoad(self.head, .acquire)
      {
        if head.ptr == tail.ptr
        { // either the queue is empty, or the tail is lagging behind
          if let nextPtr = next.ptr
          { // tail was behind the actual last node; try to advance it.
            let newTail = tail.incremented(with: nextPtr)
            CAtomicsCompareAndExchange(self.tail, tail, newTail, .strong, .release)
          }
          else
          { // queue is empty
            return nil
          }
        }
        else
        { // no need to deal with tail
          // read element before CAS, otherwise another dequeue racing ahead might free the node too early.
          if let node = Node(storage: next.ptr),
             let element = CAtomicsLoad(node.data, .acquire)
          {
            let newhead = head.incremented(with: node.storage)
            if CAtomicsCompareAndExchange(self.head, head, newhead, .weak, .release)
            {
              let pointer = element.assumingMemoryBound(to: T.self)
              CAtomicsStore(pooltail, head, .release)
              defer { pointer.deallocate() }
              return pointer.move()
            }
          }
        }
      }
    }
  }
}
