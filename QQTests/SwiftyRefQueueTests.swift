//
//  RefQueueSwift1Tests.swift
//  concurrency
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Foundation
import XCTest
import QQ

class SwiftyRefQueue1Tests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefQueueSwift1<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefQueueSwift1<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefQueueSwift1<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefQueueSwift1<dispatch_semaphore_t>.self, element: s)
  }
}

class SwiftyRefQueue2Tests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefQueueSwift2<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefQueueSwift2<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefQueueSwift2<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefQueueSwift2<dispatch_semaphore_t>.self, element: s)
  }
}

class SwiftyRefQueue3Tests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefQueueSwift3<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefQueueSwift3<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefQueueSwift3<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefQueueSwift3<dispatch_semaphore_t>.self, element: s)
  }
}

class SwiftyRefQueuePoolTests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefQueuePool<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefQueuePool<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefQueuePool<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefQueuePool<dispatch_semaphore_t>.self, element: s)
  }
}

class SwiftyRefQueueStructTests: QQTests
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

class SwiftyRefQueuePoolStructTests: QQTests
{
  func testQueue()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueueTest(RefQueuePoolStruct<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(RefQueuePoolStruct<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(RefQueuePoolStruct<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(RefQueuePoolStruct<dispatch_semaphore_t>.self, element: s)
  }
}

