//
//  QueueTests.swift
//  concurrency
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Foundation
import XCTest
import QQ

class OriginalQueueTests: QQTests
{
  func testQueue()
  {
    QueueTest(Queue<Int>.self, element: 0)
  }

  func testPerformanceFill()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestFill(Queue<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestSpin(Queue<dispatch_semaphore_t>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    var s: dispatch_semaphore_t = dispatch_semaphore_create(1)
    QueuePerformanceTestEmpty(Queue<dispatch_semaphore_t>.self, element: s)
  }
}
