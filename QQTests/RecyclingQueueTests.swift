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

class TwoLockRecyclingQueueTests: QQTests
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

class LockFreeQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LockFreeQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(LockFreeQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(LockFreeQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(LockFreeQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(LockFreeQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LockFreeQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(LockFreeQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(LockFreeQueue<Datum>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: LockFreeQueue<Datum>.self)
  }
}

class OptimisticLockFreeQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(OptimisticLockFreeQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(OptimisticLockFreeQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(OptimisticLockFreeQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(OptimisticLockFreeQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(OptimisticLockFreeQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(OptimisticLockFreeQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(OptimisticLockFreeQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(OptimisticLockFreeQueue<Datum>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: OptimisticLockFreeQueue<Datum>.self)
  }
}

class LockFreeReferenceQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LockFreeReferenceQueue<Thing>.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(LockFreeReferenceQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(LockFreeReferenceQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(LockFreeReferenceQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LockFreeReferenceQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(LockFreeReferenceQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(LockFreeReferenceQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: LockFreeReferenceQueue<Thing>.self)
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
