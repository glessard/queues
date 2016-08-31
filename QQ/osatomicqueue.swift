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

typealias QueueHead = OpaquePointer

func AtomicQueueInit() -> QueueHead
{
  // There are 3 values in OSAtomicFifoQueueHead, but the struct
  // is aligned on 16-byte boundaries on x64, translating to 32 bytes.
  // As a workaround, we assign a chunk of 4 integers.

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

  return OpaquePointer(h)
}

func AtomicQueueRelease(_ h: QueueHead)
{
  UnsafeMutableRawPointer(h).deallocate(bytes: 3*MemoryLayout<OpaquePointer>.size, alignedTo: 16)
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
