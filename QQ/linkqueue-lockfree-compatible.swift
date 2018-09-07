//
//  linkqueue-lockfree-compatible.swift
//  QQ
//
//  Created by Guillaume Lessard on 2016-12-14.
//  Copyright (c) 2016 Guillaume Lessard. All rights reserved.
//

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

final public class LockFreeCompatibleQueue<T>: QueueType
{
  public typealias Element = T

  private var head = AtomicTP<LockFreeNode<UnsafeMutablePointer<T>>>()
  private var tail = AtomicTP<LockFreeNode<UnsafeMutablePointer<T>>>()

  public init()
  {
    let node = LockFreeNode<UnsafeMutablePointer<T>>()
    head.store(TaggedPointer(node))
    tail.store(TaggedPointer(node))
  }

  deinit
  {
    // empty the queue
    while let node = head.load().pointee
    {
      node.next.pointee.load().pointee?.deinitialize()
      head.store(node.next.pointee.load())
      node.deallocate()
    }
  }

  public var isEmpty: Bool { return head.load().pointer == tail.load().pointer }

  public var count: Int {
    var i = 0
    let current = head.load().pointee!
    var pointer = current.next.pointee.load()
    while let current = pointer.pointee
    { // Iterate along the linked nodes while counting
      pointer = current.next.pointee.load()
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    pointer.initialize(to: newElement)
    let node = LockFreeNode(initializedWith: pointer)

    while true
    {
      let oldtail = tail.load()
      if let tailnode = oldtail.pointee
      {
        let oldnext = tailnode.next.pointee.load()

        if oldtail == tail.load()
        { // was tail pointing to the last node?
          if oldnext.pointer == nil
          { // try to link the new node to the end of the list
            if tailnode.next.pointee.CAS(old: oldnext, new: node)
            { // success. try to have tail point to the inserted node.
              _ = tail.CAS(old: oldtail, new: node)
              break
            }
          }
          else
          { // tail wasn't pointing to the actual last node; try to fix it.
            _ = tail.CAS(old: oldtail, new: oldnext.pointee!)
          }
        }
      }
    }
  }

  public func dequeue() -> T?
  {
    while true
    {
      let oldhead = head.load()
      let oldtail = tail.load()

      if let oldnode = oldhead.pointee
      {
        let second = oldnode.next.pointee.load().pointee

        if oldhead == head.load()
        {
          if oldnode.storage == oldtail.pointer
          { // queue empty, or tail is behind
            if second == nil
            { // queue is empty
              return nil
            }
            // tail was behind the actual last node; try to advance it.
            _ = tail.CAS(old: oldtail, new: second!)
          }
          else
          { // no need to deal with tail
            // read element before CAS, otherwise another dequeue racing ahead might free the node too early.
            let newhead = second!
            let pointer = newhead.read() // must happen before deinitialize in another thread
            if head.CAS(old: oldhead, new: newhead)
            {
              newhead.deinitialize()
              oldnode.deallocate()
              let element = pointer.move()
              pointer.deallocate()
              return element
            }
          }
        }
      }
    }
  }
}
