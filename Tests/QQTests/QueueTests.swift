//
//  QueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation
import XCTest

import QQ

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
