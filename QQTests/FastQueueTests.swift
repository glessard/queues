//
//  FastQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation
import XCTest

@testable import QQ

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
    QueuePerformanceTestFill(FastQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(FastQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(FastQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(FastQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(FastQueue<UInt32>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(FastQueue<UInt32>.self)
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
    QueuePerformanceTestFill(FastOSQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(FastOSQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(FastOSQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(FastOSQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(FastOSQueue<UInt32>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(FastOSQueue<UInt32>.self)
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
    QueuePerformanceTestFill(Fast2LockQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(Fast2LockQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(Fast2LockQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(Fast2LockQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(Fast2LockQueue<UInt32>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(Fast2LockQueue<UInt32>.self)
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
    QueuePerformanceTestFill(LockFreeFastQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(LockFreeFastQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LockFreeFastQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(LockFreeFastQueue<Thing>.self, newElement: Thing())
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
    QueuePerformanceTestFill(OptimisticFastQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(OptimisticFastQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(OptimisticFastQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(OptimisticFastQueue<Thing>.self, newElement: Thing())
  }
}


class UnsafeFastQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(UnsafeFastQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(UnsafeFastQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(UnsafeFastQueue<Thing>)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(UnsafeFastQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(UnsafeFastQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(UnsafeFastQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(UnsafeFastQueue<Thing>.self, newElement: Thing())
  }
}
