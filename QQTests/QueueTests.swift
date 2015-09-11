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
    QueueTestCount(Queue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(Queue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(Queue<Thing>)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(Queue<Thing>.self, element: Thing())
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(Queue<Thing>.self, element: Thing())
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(Queue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(Queue<Thing>.self, newElement: Thing())
  }
}
