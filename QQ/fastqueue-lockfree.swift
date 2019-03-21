//
//  fastqueue.swift
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

  private var head = AtomicTaggedMutableRawPointer()
  private var tail = AtomicTaggedMutableRawPointer()

  private let pool = AtomicStack<Node>()

  public init()
  {
    let node = Node.dummy
    let tmrp = TaggedMutableRawPointer(node.storage, tag: 1)
    head.initialize(tmrp)
    tail.initialize(tmrp)
  }

  deinit
  {
    // empty the queue
    let head = Node(storage: self.head.load(.acquire).ptr)
    var next = Node(storage: head.next.load(.acquire).ptr)
    while let node = next
    {
      next = Node(storage: node.next.load(.acquire).ptr)
      if let pointer = node.data.swap(nil, .acquire)?.assumingMemoryBound(to: T.self)
      {
        pointer.deinitialize(count: 1)
        pointer.deallocate()
      }
      node.deallocate()
    }
    head.deallocate()
  }

  public var isEmpty: Bool { return head.load(.relaxed).ptr == tail.load(.relaxed).ptr }

  public var count: Int {
    var i = 0
    let tail = Node(storage: self.tail.load(.relaxed).ptr)
    var next = Node(storage: self.head.load(.relaxed).ptr).next.load(.relaxed).ptr
    while let current = Node(storage: next)
    { // Iterate along the linked nodes while counting
      next = current.next.load(.relaxed).ptr
      i += 1
      if current == tail { break }
    }
    return i
  }

  private func node(with element: T) -> Node
  {
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    pointer.initialize(to: element)
    if let reused = pool.pop()
    {
      reused.initialize(to: pointer)
      return reused
    }
    return Node(initializedWith: pointer)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    while true
    {
      let tail = self.tail.load(.acquire)
      let tailNode = Node(storage: tail.ptr)

      let next = tailNode.next.load(.acquire)
      if let nextNode = Node(storage: next.ptr)
      { // tail wasn't pointing to the actual last node; try to fix it.
        let next = TaggedMutableRawPointer(nextNode.storage, tag: next.tag &+ 1)
        _ = self.tail.CAS(tail, next, .strong, .release)
      }
      else
      { // try to link the new node to the end of the list
        let baseNode = TaggedOptionalMutableRawPointer()
        let nextNode = next.incremented(with: node.storage)
        if tailNode.next.CAS(baseNode, nextNode, .weak, .release)
        { // success. try to have tail point to the inserted node.
          let newTail = tail.incremented(with: node.storage)
          _ = self.tail.CAS(tail, newTail, .strong, .release)
          break
        }
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let head = self.head.load(.acquire)
      let tail = self.tail.load(.relaxed)
      let next = Node(storage: head.ptr).next.load(.acquire)

      if head == self.head.load(.acquire)
      {
        if head.ptr == tail.ptr
        { // either the queue is empty, or the tail is lagging behind
          if let nextPtr = next.ptr
          { // tail was behind the actual last node; try to advance it.
            let newTail = tail.incremented(with: nextPtr)
            _ = self.tail.CAS(tail, newTail, .strong, .release)
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
             let element = node.data.load(.acquire)
          {
            let newhead = head.incremented(with: node.storage)
            if self.head.CAS(head, newhead, .weak, .release)
            {
              pool.push(Node(storage: head.ptr))
              let pointer = element.assumingMemoryBound(to: T.self)
              defer { pointer.deallocate() }
              return pointer.move()
            }
          }
        }
      }
    }
  }
}
