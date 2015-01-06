//
//  QQTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Cocoa
import XCTest
import QQ

class QQTests: XCTestCase
{
  let performanceTestIterations=300_000

  func QueueTest<E, Q: QueueType where Q.Element == E>(_: Q.Type, element: E)
  {
    var q = Q()

    for i in 1...10_000
    {
      let r = arc4random_uniform(2)

      XCTAssert(q.CountNodes() == q.count, "stored element count does not match actual element count")

      if r == 0
      {
        let b = q.count
        q.enqueue(element)
        let a = q.count
        XCTAssert(a-b == 1, "element count improperly incremented upon enqueuing")
      }
      else
      {
        let b = q.count
        if b == 0
        {
          XCTAssert(q.dequeue() == nil, "non-nil result from an empty queue")
        }
        else
        {
          if let v = q.dequeue()
          {
            XCTAssert(b-q.count == 1, "element count improperly decremented upon dequeuing")
          }
          else
          {
            XCTFail("nil result returned by a non-empty queue")
          }
        }
      }
    }

    while let e = q.dequeue()
    {
      _ = e
    }
  }

  func QueuePerformanceTestFill<E, Q: QueueType where Q.Element == E>(_: Q.Type, element: E)
  {
    self.measureBlock() {
      var q = Q()
      for i in 1...self.performanceTestIterations
      {
        q.enqueue(element)
      }

      for i in 1...self.performanceTestIterations
      {
        q.dequeue()
      }
    }
  }

  func QueuePerformanceTestSpin<E, Q: QueueType where Q.Element == E>(_: Q.Type, element: E)
  {
    self.measureBlock() {
      var q = Q()
      for i in 1...self.performanceTestIterations
      {
        q.enqueue(element)
        _ = q.dequeue()
      }
    }
  }

  func QueuePerformanceTestEmpty<E, Q: QueueType where Q.Element == E>(_: Q.Type, element: E)
  {
    self.measureBlock() {
      var q = Q()
      for i in 1...self.performanceTestIterations
      {
        q.dequeue()
      }
    }
  }
}
