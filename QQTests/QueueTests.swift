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

class GenericNodeQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(SlowQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(SlowQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(SlowQueue<Thing>)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(SlowQueue<Thing>.self, element: Thing())
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(SlowQueue<Thing>.self, element: Thing())
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(SlowQueue<Thing>.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(SlowQueue<Thing>.self, newElement: Thing())
  }
}

class RefARCQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(RefARCQueue<Thing>.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(RefARCQueue<Thing>)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(RefARCQueue<Thing>.self, element: Thing())
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(RefARCQueue<Thing>.self, element: Thing())
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(RefARCQueue<Thing>.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(RefARCQueue<Thing>.self, newElement: Thing())
  }
}
