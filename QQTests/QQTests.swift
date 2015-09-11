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

  func QueueTestCount<Q: QueueType>(_: Q.Type, element: Q.Element)
  {
    let q: Q = [element, element]
    var c = 2

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

  func QueuePerformanceTestFill<Q: QueueType>(_: Q.Type, element: Q.Element)
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

  func QueuePerformanceTestSpin<Q: QueueType>(_: Q.Type, element: Q.Element)
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

  func QueueInitEmptyTest<Q: QueueType>(_: Q.Type, newElement: Q.Element)
  {
    let q = Q(newElement)
    XCTAssert(q.isEmpty == false)

    _ = q.dequeue()
    XCTAssert(q.isEmpty == true)

    let enqueueCount = 10

    (1...enqueueCount).forEach { _ in q.enqueue(newElement) }
    let dequeueCount = q.reduce(0) { (i, _) in i+1 }

    XCTAssert(dequeueCount == enqueueCount)
  }

  func MultiThreadedBenchmark<Q: QueueType where Q.Element == Thing>(type: Q.Type)
  {
    let workers  = [3,5,7,11,19]

    workers.forEach { n in MTBenchmark(type, n) }
  }

  func MTBenchmark<Q: QueueType where Q.Element == Thing>(_: Q.Type, _ threads: Int) -> Int
  {
    guard threads > 0 else { return Int.max }

    let iterations: Int32 = 1_000_000
    var i: Int32 = 0

    let queue = Q(Thing())
    let start = mach_absolute_time()
    dispatch_apply(threads, dispatch_get_global_queue(qos_class_self(), 0)) {
      _ in
      while i < iterations
      {
        if (random() & 1) == 1
        {
          queue.enqueue(Thing())
        }
        else
        {
          if let _ = queue.dequeue()
          {
            OSAtomicIncrement32Barrier(&i)
          }
        }
      }
    }
    let dt = mach_absolute_time() - start
    print("\(threads): \t\(dt/numericCast(i))")
    return numericCast(dt)/numericCast(i)
  }
}
