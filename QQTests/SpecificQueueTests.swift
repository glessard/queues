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

class IntQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(IntQueue.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(IntQueue)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(IntQueue.self, element: 0)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(IntQueue.self, element: 0)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(IntQueue.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(IntQueue.self, newElement: 99)
  }
}

class IntOSQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(IntOSQueue.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(IntOSQueue)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(IntOSQueue.self, element: 0)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(IntOSQueue.self, element: 0)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(IntOSQueue.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(IntOSQueue.self, newElement: 99)
  }
}

class IntARCQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(IntARCQueue.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(IntARCQueue)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(IntARCQueue.self, element: 0)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(IntARCQueue.self, element: 0)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(IntARCQueue.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(IntARCQueue.self, newElement: 99)
  }
}

class ThingQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(ThingQueue.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(ThingQueue)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(ThingQueue.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(ThingQueue.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(ThingQueue.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(ThingQueue.self, newElement: Thing())
  }
}


class ThingOSQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(ThingOSQueue.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(ThingOSQueue)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(ThingOSQueue.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(ThingOSQueue.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(ThingOSQueue.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(ThingOSQueue.self, newElement: Thing())
  }
}


class ThingARCQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(ThingARCQueue.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(ThingARCQueue)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(ThingARCQueue.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(ThingARCQueue.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(ThingARCQueue.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(ThingARCQueue.self, newElement: Thing())
  }
}
