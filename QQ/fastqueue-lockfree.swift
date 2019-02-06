//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import CAtomics

/// Lock-free queue with node recycling
///
/// Note that this algorithm is not designed for tri-state memory as used in Swift.
/// This means that it does not work correctly in multi-threaded situations (as in, accesses memory in an incorrect state.)
/// It was an interesting experiment.
///
/// Lock-free queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html

final public class LockFreeFastQueue<T>: QueueType
{
  public typealias Element = T
  typealias Node = LockFreeNode<T>

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
    while true
    {
      let node = Node(storage: head.load(.relaxed).ptr)
      defer { node.deallocate() }

      let next = node.next.pointee.load(.relaxed)
      if let node = Node(storage: next.ptr)
      {
        node.deinitialize()
        let tagged = TaggedMutableRawPointer(node.storage, tag: next.tag)
        head.store(tagged, .relaxed)
      }
      else { break }
    }
  }

  public var isEmpty: Bool { return head.load(.relaxed).ptr == tail.load(.relaxed).ptr }

  public var count: Int {
    var i = 0
    let tail = Node(storage: self.tail.load(.relaxed).ptr)
    var next = Node(storage: self.head.load(.relaxed).ptr).next.pointee.load(.relaxed).ptr
    while let current = Node(storage: next)
    { // Iterate along the linked nodes while counting
      next = current.next.pointee.load(.relaxed).ptr
      i += 1
      if current == tail { break }
    }
    return i
  }

  private func node(with element: T) -> Node
  {
    if let reused = pool.pop()
    {
      reused.initialize(to: element)
      return reused
    }
    return Node(initializedWith: element)
  }

  public func enqueue(_ newElement: T)
  {
    let node = self.node(with: newElement)

    while true
    {
      let tail = self.tail.load(.acquire)
      let tailNode = Node(storage: tail.ptr)

      let next = tailNode.next.pointee.load(.acquire)
      if let nextNode = Node(storage: next.ptr)
      { // tail wasn't pointing to the actual last node; try to fix it.
        let next = TaggedMutableRawPointer(nextNode.storage, tag: next.tag &+ 1)
        _ = self.tail.CAS(tail, next, .strong, .release)
      }
      else
      { // try to link the new node to the end of the list
        let baseNode = TaggedOptionalMutableRawPointer()
        let nextNode = TaggedOptionalMutableRawPointer(node.storage, tag: next.tag &+ 1)
        if tailNode.next.pointee.CAS(baseNode, nextNode, .weak, .release)
        { // success. try to have tail point to the inserted node.
          let newTail = TaggedMutableRawPointer(node.storage, tag: tail.tag &+ 1)
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
      let next = Node(storage: head.ptr).next.pointee.load(.acquire)

      if head == self.head.load(.acquire)
      {
        if head.ptr == tail.ptr
        { // either the queue is empty, or the tail is lagging behind
          if let nextPtr = next.ptr
          { // tail was behind the actual last node; try to advance it.
            let newTail = TaggedMutableRawPointer(nextPtr, tag: tail.tag &+ 1)
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
             let element = node.read() // must happen before deinitialize in another thread
          {
            let newhead = TaggedMutableRawPointer(node.storage, tag: head.tag &+ 1)
            if self.head.CAS(head, newhead, .weak, .release)
            {
              node.deinitialize()
              pool.push(Node(storage: head.ptr))
              return element
            }
          }
        }
      }
    }
  }
}
