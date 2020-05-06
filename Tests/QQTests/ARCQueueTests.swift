//
//  ARCQueueTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-09-09.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation
import XCTest

import QQ

class ARCQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(ARCQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(ARCQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(ARCQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(ARCQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(ARCQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(ARCQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(ARCQueue<Thing>.self, newElement: Thing())
  }

  //  This one used to crash. rdar://20984816
  func testMT()
  {
    MultiThreadedBenchmark(ARCQueue<Thing>.self)
  }
}

class UnsafeARCQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(UnsafeARCQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(UnsafeARCQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(UnsafeARCQueue<Thing>.self)
  }

  func testPerformanceFill()
  {
    QueuePerformanceTestFill(UnsafeARCQueue<Thing>.self)
  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(UnsafeARCQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(UnsafeARCQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(UnsafeARCQueue<Thing>.self, newElement: Thing())
  }
}

class UnsafeArrayQueueTests: QQTests
{
  func testQueueCount()
  {
    QueueTestCount(ArrayQueue<Int>.self, element: 0)
  }

  func testQueueInt()
  {
    QueueIntTest(ArrayQueue<UInt64>.self)
  }

  func testQueueRef()
  {
    QueueRefTest(ArrayQueue<Thing>.self)
  }

//  This is obviously where an Array would fall down...
//  func testPerformanceFill()
//  {
//    QueuePerformanceTestFill(ArrayQueue<Thing>.self)
//  }

  func testPerformanceSpin()
  {
    QueuePerformanceTestSpin(ArrayQueue<Thing>.self)
  }

  func testPerformanceEmpty()
  {
    QueuePerformanceTestEmpty(ArrayQueue<Thing>.self)
  }

  func testEmpty()
  {
    QueueInitEmptyTest(ArrayQueue<Thing>.self, newElement: Thing())
  }
}
