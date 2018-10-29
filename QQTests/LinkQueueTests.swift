//
//  LinkQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation
import XCTest

@testable import QQ

class LinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(LinkQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(LinkQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(LinkQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(LinkQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LinkQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(LinkQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(LinkQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: LinkQueue<Thing>.self)
  }
}

class LinkOSQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LinkOSQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(LinkOSQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(LinkOSQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(LinkOSQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(LinkOSQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LinkOSQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(LinkOSQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(LinkOSQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: LinkOSQueue<Thing>.self)
  }
}

class DoubleLockLinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(Link2LockQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(Link2LockQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(Link2LockQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(Link2LockQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(Link2LockQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(Link2LockQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(Link2LockQueue<Thing>.self, newElement: Thing())
  }

  func testMT()
  {
    MultiThreadedBenchmark(Link2LockQueue<Thing>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: Link2LockQueue<Thing>.self)
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

class UnsafeLinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(UnsafeLinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(UnsafeLinkQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(UnsafeLinkQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(UnsafeLinkQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(UnsafeLinkQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(UnsafeLinkQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(UnsafeLinkQueue<Thing>.self, newElement: Thing())
  }
}
