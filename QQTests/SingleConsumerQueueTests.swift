//
//  MPSCQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation
import XCTest

@testable import QQ

class MPSCQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(MPSCLinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(MPSCLinkQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(MPSCLinkQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(MPSCLinkQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(MPSCLinkQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(MPSCLinkQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(MPSCLinkQueue<Thing>.self, newElement: Thing())
  }

  func testPerformanceMT()
  {
    QueuePerformanceTestMultiThreaded(type: MPSCLinkQueue<Thing>.self)
  }
}

class SPSCLinkQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(SPSCLinkQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(SPSCLinkQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(SPSCLinkQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(SPSCLinkQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(SPSCLinkQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(SPSCLinkQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(SPSCLinkQueue<Thing>.self, newElement: Thing())
  }

//  func testPerformanceMT()
//  {
//    QueuePerformanceTestMultiThreaded(type: SPSCLinkQueue<Thing>.self)
//  }
}

class SPSCFastQueueTests: QQTests
{
  func testQueue()
  {
    QueueTestCount(SPSCFastQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(SPSCFastQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(SPSCFastQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(SPSCFastQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(SPSCFastQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(SPSCFastQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(SPSCFastQueue<Thing>.self, newElement: Thing())
  }

  //  func testPerformanceMT()
  //  {
  //    QueuePerformanceTestMultiThreaded(type: SPSCFastQueue<Thing>.self)
  //  }
}
