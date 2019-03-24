//
//  MPSCQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation
import XCTest

@testable import QQ

class MPSCQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(MPSCLockFreeQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(MPSCLockFreeQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(MPSCLockFreeQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(MPSCLockFreeQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(MPSCLockFreeQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(MPSCLockFreeQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(MPSCLockFreeQueue<Thing>.self, newElement: Thing())
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: MPSCLockFreeQueue<Thing>.self)
  }
}

class MPSCRecyclingQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(MPSCLockFreeRecyclingQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(MPSCLockFreeRecyclingQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(MPSCLockFreeRecyclingQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(MPSCLockFreeRecyclingQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(MPSCLockFreeRecyclingQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(MPSCLockFreeRecyclingQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(MPSCLockFreeRecyclingQueue<Thing>.self, newElement: Thing())
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: MPSCLockFreeRecyclingQueue<Thing>.self)
  }
}

class SPSCLockFreeQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(SPSCLockFreeQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(SPSCLockFreeQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(SPSCLockFreeQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(SPSCLockFreeQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(SPSCLockFreeQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(SPSCLockFreeQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(SPSCLockFreeQueue<Thing>.self, newElement: Thing())
  }
}

class SPSCLockFreeRecyclingQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(SPSCLockFreeRecyclingQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(SPSCLockFreeRecyclingQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(SPSCLockFreeRecyclingQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(SPSCLockFreeRecyclingQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(SPSCLockFreeRecyclingQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(SPSCLockFreeRecyclingQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(SPSCLockFreeRecyclingQueue<Thing>.self, newElement: Thing())
  }
}

class SingleConsumerOptimisticQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(SingleConsumerOptimisticQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(SingleConsumerOptimisticQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(SingleConsumerOptimisticQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(SingleConsumerOptimisticQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(SingleConsumerOptimisticQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(SingleConsumerOptimisticQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(SingleConsumerOptimisticQueue<Thing>.self, newElement: Thing())
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: SingleConsumerOptimisticQueue<Thing>.self)
  }
}
