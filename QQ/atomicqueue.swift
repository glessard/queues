//
//  File.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-01-09.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//


/*
  Initialize an OSAtomicFifoQueueHead struct, even though we don't
  have the definition of it. See libkern/OSAtomic.h
*/

typealias QueueHead = COpaquePointer

func AtomicQueueInit() -> QueueHead
{
  // There are 3 values in OSAtomicFifoQueueHead, but since
  // it is aligned on 16-byte boundaries on x64, we'll
  // assign a chunk of 4.

  let h = UnsafeMutablePointer<Int>.alloc(4)
  for i in 0..<4
  {
    h.advancedBy(i).initialize(0)
  }

  return COpaquePointer(h)
}

func AtomicQueueRelease(h: QueueHead)
{
  UnsafeMutablePointer<Int>(h).dealloc(4)
}


/*
  Initialize an OSAtomicQueueHead struct, even though we don't
  have the definition of it. See libkern/OSAtomic.h
*/

typealias StackHead = COpaquePointer

func AtomicStackInit() -> StackHead
{
  let h = UnsafeMutablePointer<Int>.alloc(2)
  for i in 0..<2
  {
    h.advancedBy(i).initialize(0)
  }

  return COpaquePointer(h)
}

func AtomicStackRelease(h: StackHead)
{
  UnsafeMutablePointer<Int>(h).dealloc(2)
}
