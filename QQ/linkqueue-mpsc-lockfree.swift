//
//  linkqueue-lockfree.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-08-16.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
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

import CAtomics

final public class MPSCLinkQueue<T>: QueueType
{
  public typealias Element = T

  private var head = AtomicMutableRawPointer()
  private var tail = AtomicMutableRawPointer()

  public init()
  {
    let node = WaitFreeNode<T>()
    head.initialize(node)
    tail.initialize(node)
  }

  deinit {
    // empty the queue
    var node: WaitFreeNode<T>
    while true
    {
      node = head.getNode(order: .acquire)
      defer { node.deallocate() }

      guard let next = node.getNextNode(order: .acquire)
        else { break }

      head.setNode(next, order: .release)
    }
  }

  public var isEmpty: Bool { return head.load(.relaxed) == tail.load(.relaxed) }

  public var count: Int {
    var i = 0
    let tail: WaitFreeNode<T>  = self.tail.getNode(order: .acquire)
    var next: WaitFreeNode<T>? = self.head.getNode(order: .acquire)
    while let node = next, node != tail
    { // Iterate along the linked nodes while counting
      repeat {
        next = node.getNextNode(order: .acquire)
      } while next == nil
      i += 1
    }
    return i
  }

  public func enqueue(_ newElement: T)
  {
    let node = WaitFreeNode(newElement)

    let previousTail = self.tail.swap(node: node)
    previousTail.setNextNode(node)
  }

  public func dequeue() -> T?
  {
    let head: WaitFreeNode<T>  = self.head.getNode(order: .acquire)
    var next: WaitFreeNode<T>? = head.getNextNode(order: .acquire)
    if let next = next
    {
      let element = next.read()
      next.clear()
      self.head.setNode(next)
      head.deallocate()
      return element
    }
    else if tail.getNode(order: .acquire) != head
    {
      repeat { /* waiting */
        next = WaitFreeNode<T>(head.next.pointee.load(.acquire))
      } while next == nil
      let next = next! // grumble

      let element = next.read()
      next.clear()
      self.head.setNode(next)
      head.deallocate()
      return element
    }
    return nil
  }
}

extension AtomicMutableRawPointer
{
  mutating fileprivate func initialize<T>(_ node: WaitFreeNode<T>)
  {
    self.initialize(node.storage)
  }

  mutating fileprivate func getNode<T>(order: LoadMemoryOrder) -> WaitFreeNode<T>
  {
    return WaitFreeNode(self.load(order))!
  }

  mutating fileprivate func setNode<T>(_ node: WaitFreeNode<T>, order: StoreMemoryOrder = .release)
  {
    self.store(node.storage, order)
  }

  mutating fileprivate func swap<T>(node: WaitFreeNode<T>, order: MemoryOrder = .acqrel) -> WaitFreeNode<T>
  {
    let pointer = self.swap(node.storage, order)!
    return WaitFreeNode(storage: pointer)
  }
}

private let nextOffset = MemoryLayout<UnsafeMutableRawPointer>.stride
private let dataOffset = nextOffset + MemoryLayout<AtomicMutableRawPointer>.stride

private struct WaitFreeNode<Element>: OSAtomicNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  init?(_ p: UnsafeMutableRawPointer?)
  {
    guard let storage = p else { return nil }
    self.storage = storage
  }

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  init(_ element: Element? = nil)
  {
    let size = dataOffset + MemoryLayout<Element?>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 16)
    storage.bindMemory(to: (UnsafeMutableRawPointer?).self, capacity: 1)
    storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = nil
    (storage+nextOffset).bindMemory(to: AtomicMutableRawPointer.self, capacity: 1)
    (storage+nextOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self).pointee = AtomicMutableRawPointer()
    (storage+nextOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self).pointee.initialize(nil)
    (storage+dataOffset).bindMemory(to: (Element?).self, capacity: 1).initialize(to: element)
  }

  func deallocate()
  {
    (storage+dataOffset).assumingMemoryBound(to: (Element?).self).deinitialize(count: 1)
    storage.deallocate()
  }

  var next: UnsafeMutablePointer<AtomicMutableRawPointer> {
    get {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self)
    }
  }

  func getNextNode(order: LoadMemoryOrder = .acquire) -> WaitFreeNode?
  {
    return WaitFreeNode(next.pointee.load(order))
  }

  func setNextNode(_ node: WaitFreeNode, order: StoreMemoryOrder = .release)
  {
    next.pointee.store(node.storage, order)
  }

  func initialize(to element: Element)
  {
    storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = nil
    (storage+nextOffset).assumingMemoryBound(to: AtomicMutableRawPointer.self).pointee.initialize(nil)
    (storage+dataOffset).assumingMemoryBound(to: (Element?).self).pointee = nil
  }

  func read() -> Element?
  {
    return (storage+dataOffset).assumingMemoryBound(to: (Element?).self).pointee
  }

  func clear()
  {
    (storage+dataOffset).assumingMemoryBound(to: (Element?).self).pointee = nil
  }
}
