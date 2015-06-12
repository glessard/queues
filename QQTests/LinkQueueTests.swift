//
//  LinkQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation
import XCTest

@testable import QQ

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
    let s = Thing()
    QueuePerformanceTestFill(LinkQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(LinkQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LinkQueue<Thing>.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(LinkQueue<Thing>.self, newElement: Thing())
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
    let s = Thing()
    QueuePerformanceTestFill(LinkOSQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(LinkOSQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(LinkOSQueue<Thing>.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(LinkOSQueue<Thing>.self, newElement: Thing())
  }
}

class DoubleLockLinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(Link2LockQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(Link2LockQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(Link2LockQueue<Thing>)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(Link2LockQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(Link2LockQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(Link2LockQueue<Thing>.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(Link2LockQueue<Thing>.self, newElement: Thing())
  }
}

class OptimisticLinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(OptimisticLinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(OptimisticLinkQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(OptimisticLinkQueue<Thing>)
  }

  func testPerformanceFill()
  {
    let s = Thing()
    QueuePerformanceTestFill(OptimisticLinkQueue<Thing>.self, element: s)
  }

  func testPerformanceSpin()
  {
    let s = Thing()
    QueuePerformanceTestSpin(OptimisticLinkQueue<Thing>.self, element: s)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(OptimisticLinkQueue<Thing>.self)
  }

  func testExtra()
  {
    QueueInitEmptyTest(OptimisticLinkQueue<Thing>.self, newElement: Thing())
  }
}
