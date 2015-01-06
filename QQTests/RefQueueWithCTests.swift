//
//  RefQueueTests.swift
//  concurrency
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Foundation
import XCTest
import QQ

class RefQueueC1Tests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefQueue<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefQueue<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefQueue<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefQueue<dispatch_semaphore_t>.self, element: s)
  }
}

class RefQueueStructTests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefQueueStruct<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefQueueStruct<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefQueueStruct<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefQueueStruct<dispatch_semaphore_t>.self, element: s)
  }
}

class RefQueueC2Tests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefQueueC2<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefQueueC2<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefQueueC2<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefQueueC2<dispatch_semaphore_t>.self, element: s)
  }
}

class RefQueueC3Tests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefQueueC3<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefQueueC3<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefQueueC3<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefQueueC3<dispatch_semaphore_t>.self, element: s)
  }
}

class RefDoubleQueueTests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefDoubleQueue<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefDoubleQueue<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefDoubleQueue<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefDoubleQueue<dispatch_semaphore_t>.self, element: s)
  }
}

class RefDoubleQueueStructTests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefDoubleQueueStruct<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefDoubleQueueStruct<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefDoubleQueueStruct<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefDoubleQueue<dispatch_semaphore_t>.self, element: s)
  }
}
