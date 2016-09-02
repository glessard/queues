//
//  atomicqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-01-09.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

/// An interface for a node to be used with AtomicQueue (OSAtomicFifoQueue)
/// and AtomicStack (OSAtomicQueue).
/// The first bytes of the storage MUST be available for use as the link
/// pointer by `AtomicQueue.enqueue()` or `AtomicStack.push()`

protocol OSAtomicNode
{
  init(storage: UnsafeMutableRawPointer)
  var storage: UnsafeMutableRawPointer { get }
}

import func Darwin.libkern.OSAtomic.OSAtomicFifoEnqueue
import func Darwin.libkern.OSAtomic.OSAtomicFifoDequeue

/// A wrapper for OSAtomicFifoQueue

struct AtomicQueue<Node: OSAtomicNode>
{
  private let head: OpaquePointer

  init()
  {
    // Initialize an OSFifoQueueHead struct, even though we don't
    // have the definition of it. See libkern/OSAtomic.h
    //
    //  typedef	volatile struct {
    //    void	*opaque1;
    //    void	*opaque2;
    //    int	 opaque3;
    //  } __attribute__ ((aligned (16))) OSFifoQueueHead;

    let size = MemoryLayout<OpaquePointer>.size
    let count = 3

    let h = UnsafeMutableRawPointer.allocate(bytes: count*size, alignedTo: 16)
    for i in 0..<count
    {
      h.storeBytes(of: nil, toByteOffset: i*size, as: Optional<OpaquePointer>.self)
    }

    head = OpaquePointer(h)
  }

  var isEmpty: Bool {
    return UnsafeMutablePointer<OpaquePointer?>(head).pointee == nil
  }

  public var count: Int {
    var i = 0
    var node = UnsafePointer<UnsafeRawPointer?>(head).pointee
    while let current = node
    { // Iterate along the linked nodes while counting
      node = current.assumingMemoryBound(to: (UnsafeRawPointer?).self).pointee
      i += 1
    }
    return i
  }

  func release()
  {
    UnsafeMutableRawPointer(head).deallocate(bytes: 3*MemoryLayout<OpaquePointer>.size, alignedTo: 16)
  }

  func enqueue(_ node: Node)
  {
    OSAtomicFifoEnqueue(head, node.storage, 0)
  }

  func dequeue() -> Node?
  {
    if let bytes = OSAtomicFifoDequeue(head, 0)
    {
      return Node(storage: bytes)
    }
    return nil
  }
}


import func Darwin.libkern.OSAtomic.OSAtomicEnqueue
import func Darwin.libkern.OSAtomic.OSAtomicDequeue

/// A wrapper for OSAtomicQueue

struct AtomicStack<Node: OSAtomicNode>
{
  private let head: OpaquePointer

  init()
  {
    // Initialize an OSQueueHead struct, even though we don't
    // have the definition of it. See libkern/OSAtomic.h
    //
    //  typedef volatile struct {
    //    void	*opaque1;
    //    long	 opaque2;
    //  } __attribute__ ((aligned (16))) OSQueueHead;

    let size = MemoryLayout<OpaquePointer>.size
    let count = 2

    let h = UnsafeMutableRawPointer.allocate(bytes: count*size, alignedTo: 16)
    for i in 0..<count
    {
      h.storeBytes(of: nil, toByteOffset: i*size, as: Optional<OpaquePointer>.self)
    }

    head = OpaquePointer(h)
  }

  func release()
  {
    UnsafeMutableRawPointer(head).deallocate(bytes: 2*MemoryLayout<OpaquePointer>.size, alignedTo: 16)
  }

  func push(_ node: Node)
  {
    OSAtomicEnqueue(head, node.storage, 0)
  }

  func pop() -> Node?
  {
    if let bytes = OSAtomicDequeue(head, 0)
    {
      return Node(storage: bytes)
    }
    return nil
  }
}

private let offset = MemoryLayout<UnsafeMutableRawPointer>.stride

struct QueueNode<Element>: OSAtomicNode
{
  let storage: UnsafeMutableRawPointer

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  init()
  {
    let size = offset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(bytes: size, alignedTo: 16)
    storage.bindMemory(to: (UnsafeMutableRawPointer?).self, capacity: 1).pointee = nil
    (storage+offset).bindMemory(to: Element.self, capacity: 1)
  }

  func deallocate()
  {
    let size = offset + MemoryLayout<Element>.stride
    storage.deallocate(bytes: size, alignedTo: MemoryLayout<UnsafeMutableRawPointer>.alignment)
  }

  var next: QueueNode? {
    get {
      if let s = storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee
      {
        return QueueNode(storage: s)
      }
      return nil
    }
    nonmutating set {
      storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = newValue?.storage
    }
  }

  func initialize(to element: Element)
  {
    storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = nil
    (storage+offset).assumingMemoryBound(to: Element.self).initialize(to: element)
  }

  func deinitialize()
  {
    (storage+offset).assumingMemoryBound(to: Element.self).deinitialize()
  }

  @discardableResult
  func move() -> Element
  {
    return (storage+offset).assumingMemoryBound(to: Element.self).move()
  }
}
