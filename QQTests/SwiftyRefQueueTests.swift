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

class SwiftyRefQueueTests: QQTests
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
