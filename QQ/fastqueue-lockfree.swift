//
//  fastqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

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

  private var head = AtomicTP<LockFreeNode<T>>()
  private var tail = AtomicTP<LockFreeNode<T>>()

  private let pool = AtomicStack<LockFreeNode<T>>()

  public init()
  {
    let node = LockFreeNode<T>()
    head.store(TaggedPointer(node))
    tail.store(TaggedPointer(node))
  }

  deinit
  {
    // empty the queue
    while let node = head.load()?.pointee
    {
      defer { node.deallocate() }

      if let next = node.next.pointee.load()
      {
        next.pointee.deinitialize()
        head.store(next)
      }
      else { break }
    }

    // drain the pool
    while let node = pool.pop()
    {
      node.deallocate()
    }
    pool.release()
  }

  public var isEmpty: Bool { return head.load()?.pointer == tail.load()?.pointer }

  public var count: Int {
    var i = 0
    let current = head.load()!.pointee
    var pointer = current.next.pointee.load()
    while let current = pointer?.pointee
    { // Iterate along the linked nodes while counting
      pointer = current.next.pointee.load()
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = pool.pop() ?? LockFreeNode()
    node.initialize(to: newElement)

    while true
    {
      let oldtail = self.tail.load()!
      let oldnext = oldtail.pointee.next.pointee.load()

        if oldtail == self.tail.load()
        { // was tail pointing to the last node?
          if oldnext == nil
          { // try to link the new node to the end of the list
            if oldtail.pointee.next.pointee.CAS(old: oldnext, new: node)
            { // success. try to have tail point to the inserted node.
              _ = self.tail.CAS(old: oldtail, new: node)
              break
            }
          }
          else
          { // tail wasn't pointing to the actual last node; try to fix it.
            _ = self.tail.CAS(old: oldtail, new: oldnext!.pointee)
          }
        }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let oldhead = self.head.load()!
      let oldtail = self.tail.load()!

        let second = oldhead.pointee.next.pointee.load()?.pointee

        if oldhead == self.head.load()
        {
          if oldhead.pointer == oldtail.pointer
          { // queue empty, or tail is behind
            if second == nil
            { // queue is empty
              return nil
            }
            // tail was behind the actual last node; try to advance it.
            _ = self.tail.CAS(old: oldtail, new: second!)
          }
          else
          { // no need to deal with tail
            // read element before CAS, otherwise another dequeue racing ahead might free the node too early.
            if let newhead = second,
               let element = newhead.read(), // must happen before deinitialize in another thread
               head.CAS(old: oldhead, new: newhead)
            {
              newhead.deinitialize()
              pool.push(oldhead.pointee)
              return element
            }
          }
        }
    }
  }
}
