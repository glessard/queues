//
//  LinkQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Foundation
import XCTest
import QQ

class LinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(LinkQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(LinkQueue<Thing>)
  }

  func testPerformanceFill()
  {
    var s = Thing()
    QueuePerformanceTestFill(LinkQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
    QueuePerformanceTestSpin(LinkQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LinkQueue<Thing>.self)
  }
}

class LinkOSQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(LinkOSQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(LinkOSQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(LinkOSQueue<Thing>)
  }

  func testPerformanceFill()
  {
    var s = Thing()
    QueuePerformanceTestFill(LinkOSQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
    QueuePerformanceTestSpin(LinkOSQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LinkOSQueue<Thing>.self)
  }
}