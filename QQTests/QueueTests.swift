//
//  QueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Foundation
import XCTest
import QQ

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
    let s = Thing()
    QueuePerformanceTestFill(SlowQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(SlowQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(SlowQueue<Thing>.self)
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
    let s = Thing()
    QueuePerformanceTestFill(RefARCQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(RefARCQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(RefARCQueue<Thing>.self)
  }
}
