//
//  atomicqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-01-09.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//


/*
  Initialize an OSFifoQueueHead struct, even though we don't
  have the definition of it. See libkern/OSAtomic.h
*/

import func Darwin.libkern.OSAtomic.OSAtomicFifoEnqueue
import func Darwin.libkern.OSAtomic.OSAtomicFifoDequeue

struct AtomicQueue<T>
{
  private let head: OpaquePointer

  init()
  {
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

  func enqueue(_ node: UnsafeMutablePointer<T>)
  {
    OSAtomicFifoEnqueue(head, UnsafeMutableRawPointer(node), 0)
  }

  func dequeue() -> UnsafeMutablePointer<T>?
  {
    return OSAtomicFifoDequeue(head, 0)?.assumingMemoryBound(to: T.self)
  }
}

/*
  Initialize an OSQueueHead struct, even though we don't
  have the definition of it. See libkern/OSAtomic.h
*/

import func Darwin.libkern.OSAtomic.OSAtomicEnqueue
import func Darwin.libkern.OSAtomic.OSAtomicDequeue

struct AtomicStack<T>
{
  private let head: OpaquePointer

  init()
  {
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

  func push(_ node: UnsafeMutablePointer<T>)
  {
    OSAtomicEnqueue(head, UnsafeMutableRawPointer(node), 0)
  }

  func pop() -> UnsafeMutablePointer<T>?
  {
    return OSAtomicDequeue(head, 0)?.assumingMemoryBound(to: T.self)
  }
}
