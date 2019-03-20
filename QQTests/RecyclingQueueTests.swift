//
//  RecyclingQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation
import XCTest

@testable import QQ

class RecyclingQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(RecyclingQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(RecyclingQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(RecyclingQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(RecyclingQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(RecyclingQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(RecyclingQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(RecyclingQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(RecyclingQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: RecyclingQueue<Thing>.self)
  }
}

class RecyclingOSQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(RecyclingOSQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(RecyclingOSQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(RecyclingOSQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(RecyclingOSQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(RecyclingOSQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(RecyclingOSQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(RecyclingOSQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(RecyclingOSQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: RecyclingOSQueue<Thing>.self)
  }
}

class TwoLockFastQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(TwoLockRecyclingQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(TwoLockRecyclingQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(TwoLockRecyclingQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(TwoLockRecyclingQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(TwoLockRecyclingQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(TwoLockRecyclingQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(TwoLockRecyclingQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(TwoLockRecyclingQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: TwoLockRecyclingQueue<Thing>.self)
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
    QueueIntTest(LockFreeFastQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(LockFreeFastQueue<Thing>.self)
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

  func testMT()
  {
    MultiThreadedBenchmark(LockFreeFastQueue<Datum>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: LockFreeFastQueue<Datum>.self)
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
    QueueIntTest(OptimisticFastQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(OptimisticFastQueue<Thing>.self)
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

  func testMT()
  {
    MultiThreadedBenchmark(OptimisticFastQueue<Datum>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: OptimisticFastQueue<Datum>.self)
  }
}


class UnsafeRecyclingQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(UnsafeRecyclingQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(UnsafeRecyclingQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(UnsafeRecyclingQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(UnsafeRecyclingQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(UnsafeRecyclingQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(UnsafeRecyclingQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(UnsafeRecyclingQueue<Thing>.self, newElement: Thing())
  }
}
