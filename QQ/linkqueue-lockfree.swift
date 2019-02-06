//
//  linkqueue-lockfree.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import CAtomics

private let nullNode = TaggedOptionalMutableRawPointer(nil, tag: 0)

/// Lock-free queue
///
/// Note that this algorithm is not designed for tri-state memory as used in Swift.
/// This means that it does not work correctly in multi-threaded situations (as in, accesses memory in an incorrect state.)
/// It was an interesting experiment.
///
/// Lock-free queue algorithm adapted from Maged M. Michael and Michael L. Scott.,
/// "Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms",
/// in Principles of Distributed Computing '96 (PODC96)
/// See also: http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html

final public class LockFreeLinkQueue<T>: QueueType
{
  public typealias Element = T
  typealias Node = LockFreeNode<T>

  private var head = AtomicTaggedMutableRawPointer()
  private var tail = AtomicTaggedMutableRawPointer()

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

  public func enqueue(_ newElement: T)
  {
    let node = LockFreeNode(initializedWith: newElement)

    while true
    {
      let origTail = self.tail.load(.acquire)
      let tailNode = Node(storage: origTail.ptr)

      let origNext = tailNode.next.pointee.load(.acquire)
      if let nextNode = Node(storage: origNext.ptr)
      { // tail wasn't pointing to the actual last node; try to fix it.
        let next = TaggedMutableRawPointer(nextNode.storage, tag: origNext.tag &+ 1)
        _ = self.tail.CAS(origTail, next, .strong, .release)
      }
      else
      { // try to link the new node to the end of the list
        let nextNode = origNext.incremented(with: node.storage)
        if tailNode.next.pointee.CAS(nullNode, nextNode, .weak, .release)
        { // success. try to have tail point to the inserted node.
          let tail = origTail.incremented(with: node.storage)
          _ = self.tail.CAS(origTail, tail, .strong, .release)
          break
        }
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let origHead = self.head.load(.acquire)
      let origTail = self.tail.load(.relaxed)
      let origNext = Node(storage: origHead.ptr).next.pointee.load(.acquire)

      if origHead == self.head.load(.acquire)
      {
        if origHead.ptr == origTail.ptr
        { // either the queue is empty, or the tail is lagging behind
          if let next = origNext.ptr
          { // tail was behind the actual last node; try to advance it.
            let next = origTail.incremented(with: next)
            _ = self.tail.CAS(origTail, next, .strong, .release)
          }
          else
          { // queue is empty
            return nil
          }
        }
        else
        { // no need to deal with tail
          // read element before CAS, otherwise another dequeue racing ahead might free the node too early.
          if let node = Node(storage: origNext.ptr),
             let element = node.read() // must happen before deinitialize in another thread
          {
            let head = origHead.incremented(with: node.storage)
            if self.head.CAS(origHead, head, .weak, .release)
            {
              node.deinitialize()
              Node(storage: origHead.ptr).deallocate()
              return element
            }
          }
        }
      }
    }
  }
}
