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
    QueueIntTest(LinkQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(LinkQueue<Thing>)
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
    MultiThreadedBenchmark(LinkQueue<UInt32>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(LinkQueue<UInt32>.self)
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
    QueueIntTest(LinkOSQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(LinkOSQueue<Thing>)
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
    MultiThreadedBenchmark(LinkOSQueue<UInt32>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(LinkOSQueue<UInt32>.self)
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
    QueueIntTest(Link2LockQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(Link2LockQueue<Thing>)
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
    MultiThreadedBenchmark(Link2LockQueue<UInt32>.self)
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(Link2LockQueue<UInt32>.self)
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
    QueueIntTest(LockFreeLinkQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(LockFreeLinkQueue<Thing>)
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
}

class OptimisticLinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(OptimisticLinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(OptimisticLinkQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(OptimisticLinkQueue<Thing>)
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
}

class UnsafeLinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(UnsafeLinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(UnsafeLinkQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(UnsafeLinkQueue<Thing>)
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
