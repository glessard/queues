//
//  FastQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Foundation
import XCTest
import QQ

class FastQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(FastQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(FastQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(FastQueue<Thing>)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(FastQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(FastQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(FastQueue<Thing>.self)
  }
}

class FastOSQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(FastOSQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(FastOSQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(FastOSQueue<Thing>)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(FastOSQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(FastOSQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(FastOSQueue<Thing>.self)
  }
}

class DoubleLockFastQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(Fast2LockQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(Fast2LockQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(Fast2LockQueue<Thing>)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(Fast2LockQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(Fast2LockQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(Fast2LockQueue<Thing>.self)
  }
}

class LockFreeFastQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LockFreeFastQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(LockFreeFastQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(LockFreeFastQueue<Thing>)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(LockFreeFastQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(LockFreeFastQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LockFreeFastQueue<Thing>.self)
  }
}


class OptimisticFastQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(OptimisticFastQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(OptimisticFastQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(OptimisticFastQueue<Thing>)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(OptimisticFastQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(OptimisticFastQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(OptimisticFastQueue<Thing>.self)
  }
}
