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
    var s = Thing()
    QueuePerformanceTestFill(FastQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
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
    var s = Thing()
    QueuePerformanceTestFill(FastOSQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
    QueuePerformanceTestSpin(FastOSQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(FastOSQueue<Thing>.self)
  }
}

class FastDoubleLockQueueTests: QQTests
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
    var s = Thing()
    QueuePerformanceTestFill(Fast2LockQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
    QueuePerformanceTestSpin(Fast2LockQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(Fast2LockQueue<Thing>.self)
  }
}

class FastLockFreeQueueTests: QQTests
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
    var s = Thing()
    QueuePerformanceTestFill(LockFreeFastQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
    QueuePerformanceTestSpin(LockFreeFastQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LockFreeFastQueue<Thing>.self)
  }
}
