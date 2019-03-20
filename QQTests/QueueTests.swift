//
//  QueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation
import XCTest

@testable import QQ

class QueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(Queue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(Queue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(Queue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(Queue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(Queue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(Queue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(Queue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(Queue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: Queue<Thing>.self)
  }
}

class OSQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(OSQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(OSQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(OSQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(OSQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(OSQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(OSQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(OSQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(OSQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: OSQueue<Thing>.self)
  }
}

class TwoLockQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(TwoLockQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(TwoLockQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(TwoLockQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(TwoLockQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(TwoLockQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(TwoLockQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(TwoLockQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(TwoLockQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: TwoLockQueue<Thing>.self)
  }
}

class LockFreeLinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LockFreeLinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(LockFreeLinkQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(LockFreeLinkQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(LockFreeLinkQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(LockFreeLinkQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LockFreeLinkQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(LockFreeLinkQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(LockFreeLinkQueue<Datum>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: LockFreeLinkQueue<Datum>.self)
  }
}

class LockFreeLinkReferenceQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LockFreeLinkReferenceQueue<Thing>.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(LockFreeLinkReferenceQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(LockFreeLinkReferenceQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(LockFreeLinkReferenceQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LockFreeLinkReferenceQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(LockFreeLinkReferenceQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(LockFreeLinkReferenceQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: LockFreeLinkReferenceQueue<Thing>.self)
  }
}

class LockFreeCompatibleQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LockFreeCompatibleQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(LockFreeCompatibleQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(LockFreeCompatibleQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(LockFreeCompatibleQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(LockFreeCompatibleQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LockFreeCompatibleQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(LockFreeCompatibleQueue<Thing>.self, newElement: Thing())
  }

//  func testMT()
//  {
//    MultiThreadedBenchmark(LockFreeCompatibleQueue<Thing>.self)
//  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: LockFreeCompatibleQueue<Thing>.self)
  }
}

class OptimisticLinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(OptimisticLinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(OptimisticLinkQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(OptimisticLinkQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(OptimisticLinkQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(OptimisticLinkQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(OptimisticLinkQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(OptimisticLinkQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(OptimisticLinkQueue<Datum>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: OptimisticLinkQueue<Datum>.self)
  }
}

class UnsafeQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(UnsafeQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(UnsafeQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(UnsafeQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(UnsafeQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(UnsafeQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(UnsafeQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(UnsafeQueue<Thing>.self, newElement: Thing())
  }
}
