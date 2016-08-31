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

  let h = UnsafeMutablePointer<Int>.allocate(capacity: 4)
  for i in 0..<4
  {
    h.advanced(by: i).initialize(to: 0)
  }

  // Check pointer alignment
  // assert(unsafeBitCast(h, Word.self) & 0x7 == 0)

  return OpaquePointer(h)
}

func AtomicQueueRelease(_ h: QueueHead)
{
  UnsafeMutablePointer<Int>(h).deallocate(capacity: 4)
}


/*
  Initialize an OSQueueHead struct, even though we don't
  have the definition of it. See libkern/OSAtomic.h
*/

typealias StackHead = OpaquePointer

func AtomicStackInit() -> StackHead
{
  //  typedef volatile struct {
  //    void	*opaque1;
  //    long	 opaque2;
  //  } __attribute__ ((aligned (16))) OSQueueHead;

  let h = UnsafeMutablePointer<Int>.allocate(capacity: 2)
  for i in 0..<2
  {
    h.advanced(by: i).initialize(to: 0)
  }

  // Check pointer alignment
  // assert(unsafeBitCast(h, Word.self) & 0x7 == 0)

  return OpaquePointer(h)
}

func AtomicStackRelease(_ h: StackHead)
{
  UnsafeMutablePointer<Int>(h).deallocate(capacity: 2)
}
