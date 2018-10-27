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
