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

  //  This one tends to crash. rdar://20984816
  //  func testMT()
  //  {
  //    MultiThreadedBenchmark(Queue<UInt32>.self)
  //  }
}

class UnsafeQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(UnsafeQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(UnsafeQueue<UInt64>)
  }

  func testQueueRef()
  {
    QueueRefTest(UnsafeQueue<Thing>)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(UnsafeQueue<Thing>.self, element: Thing())
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(UnsafeQueue<Thing>.self, element: Thing())
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(UnsafeQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(UnsafeQueue<Thing>.self, newElement: Thing())
  }
}
