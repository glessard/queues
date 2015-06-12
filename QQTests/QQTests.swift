//
//  QQTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Cocoa
import XCTest

@testable import QQ

class QQTests: XCTestCase
{
  let performanceTestIterations=900_000

  func QueueTestCount<E, Q: QueueType where Q.Element == E>(_: Q.Type, element: E)
  {
    let q = Q()
    var c = 0

    for _ in 1...1_000
    {
      let r = arc4random_uniform(2)

      if r == 0
      {
        let a = q.count
        q.enqueue(element)
        c += 1
        let b = q.count
        XCTAssert(b-a == 1, "element count improperly incremented upon enqueuing")
        XCTAssert(c == b)
      }
      else
      {
        if c == 0
        {
          XCTAssert(q.dequeue() == nil, "non-nil result from an empty queue")
        }
        else
        {
          let a = q.count
          if let _ = q.dequeue()
          {
            c -= 1
            let b = q.count
            XCTAssert(a-b == 1, "element count improperly decremented upon dequeuing")
            XCTAssert(c == b)
          }
          else
          {
            XCTFail("nil result returned by a non-empty queue")
          }
        }
      }
    }
  }

  func QueueRefTest<Q: QueueType where Q.Element == Thing>(_: Q.Type)
  {
    let q = Q()
    let iterations = 100
    var a = Array<Thing>()

    for i in 0..<iterations
    {
      a.append(Thing())
      q.enqueue(a[i])
    }

    for i in 0..<iterations
    {
      if let t = q.dequeue()
      {
        XCTAssert(t.id == a[i].id, "Wrong object dequeued")
      }
    }
  }

  func QueueIntTest<Q: QueueType where Q.Element == UInt64>(_: Q.Type)
  {
    let q = Q()
    let iterations = 100
    var a = Array<UInt64>(count: iterations, repeatedValue: 0)

    for i in 0..<iterations
    {
      a[i] = UInt64(arc4random())
      q.enqueue(a[i])
    }

    for i in 0..<iterations
    {
      if let r = q.dequeue()
      {
        XCTAssert(r == a[i], "Wrong object dequeued")
      }
    }
  }

  func QueuePerformanceTestFill<E, Q: QueueType where Q.Element == E>(_: Q.Type, element: E)
  {
    self.measureBlock() {
      let q = Q()
      for _ in 1...self.performanceTestIterations
      {
        q.enqueue(element)
      }

      for _ in 1...self.performanceTestIterations
      {
        q.dequeue()
      }
    }
  }

  func QueuePerformanceTestSpin<E, Q: QueueType where Q.Element == E>(_: Q.Type, element: E)
  {
    self.measureBlock() {
      let q = Q()
      for _ in 1...self.performanceTestIterations
      {
        q.enqueue(element)
        _ = q.dequeue()
      }
    }
  }

  func QueuePerformanceTestEmpty<Q: QueueType>(_: Q.Type)
  {
    self.measureBlock() {
      let q = Q()
      for _ in 1...self.performanceTestIterations
      {
        q.dequeue()
      }
    }
  }

  func QueueInitEmptyTest<Q: QueueType, T where Q.Element == T>(_: Q.Type, newElement: T)
  {
    let q = Q(newElement)
    XCTAssert(q.isEmpty == false)

    _ = q.dequeue()

    XCTAssert(q.isEmpty == true)

    let testenqueues = 10

    for _ in 1...testenqueues
    {
      q.enqueue(newElement)
    }

    var j = Int.min
    for (i,_) in q.enumerate()
    {
      j = i+1
    }
    XCTAssert(j == testenqueues)
  }
}
