//
//  RefQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin
import Foundation
import XCTest
import QQ


class RefLinkQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(RefLinkQueue<Thing>.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(RefLinkQueue<Thing>)
  }

  func testPerformanceFill()
  {
    var s = Thing()
    QueuePerformanceTestFill(RefLinkQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
    QueuePerformanceTestSpin(RefLinkQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(RefLinkQueue<Thing>.self)
  }
}


class RefFastQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(RefFastQueue<Thing>.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(RefFastQueue<Thing>)
  }

  func testPerformanceFill()
  {
    var s = Thing()
    QueuePerformanceTestFill(RefFastQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
    QueuePerformanceTestSpin(RefFastQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(RefFastQueue<Thing>.self)
  }
}


class RefLinkOSQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(RefLinkOSQueue<Thing>.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(RefLinkOSQueue<Thing>)
  }

  func testPerformanceFill()
  {
    var s = Thing()
    QueuePerformanceTestFill(RefLinkOSQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
    QueuePerformanceTestSpin(RefLinkOSQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(RefLinkOSQueue<Thing>.self)
  }
}


class RefFastOSQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(RefFastOSQueue<Thing>.self, element: Thing())
  }

  func testQueueRef()
  {
    QueueRefTest(RefFastOSQueue<Thing>)
  }

  func testPerformanceFill()
  {
    var s = Thing()
    QueuePerformanceTestFill(RefFastOSQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    var s = Thing()
    QueuePerformanceTestSpin(RefFastOSQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(RefFastOSQueue<Thing>.self)
  }
}
