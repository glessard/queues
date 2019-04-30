//
//  QQTests.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Cocoa
import XCTest

import CAtomics

@testable import QQ

class QQTests: XCTestCase
{
  let performanceTestIterations=900_000

  func QueueTestCount<Q: QueueType>(_: Q.Type, element: Q.Element)
  {
    let q = Q()
    q.enqueue(element)
    q.enqueue(element)
    var c = 2
    guard q.count == c else
    {
      XCTAssertEqual(c, q.count, "\(q.count) elements counted, should be 2")
      return
    }

    for _ in 1...1_000
    {
      let r = arc4random_uniform(2)

      if r == 0
      {
        let a = q.count
        q.enqueue(element)
        c += 1
        let b = q.count
        XCTAssertEqual(b-a, 1, "element count improperly incremented: \(b) ≠ \(a)+1")
        XCTAssertEqual(c, b, "expected \(c) and \(b) equal")
      }
      else
      {
        if c == 0
        {
          XCTAssertNil(q.dequeue(), "non-nil result from an empty queue")
        }
        else
        {
          let a = q.count
          if let _ = q.dequeue()
          {
            c -= 1
            let b = q.count
            XCTAssertEqual(a-b, 1, "element count improperly decremented upon dequeuing")
            XCTAssertEqual(c, b, "expected \(c) and \(b) equal")
          }
          else
          {
            XCTFail("nil result returned by a non-empty queue")
          }
        }
      }
    }
  }

  func QueueRefTest<Q: QueueType>(_: Q.Type) where Q.Element == Thing
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
        XCTAssertEqual(t.id, a[i].id, "Wrong object dequeued")
      }
    }
  }

  func QueueIntTest<Q: QueueType>(_: Q.Type) where Q.Element == UInt64
  {
    let q = Q()
    let iterations = 100
    var a = Array<UInt64>(repeating: 0, count: iterations)

    for i in 0..<iterations
    {
      a[i] = UInt64(arc4random())
      q.enqueue(a[i])
    }

    for i in 0..<iterations
    {
      if let r = q.dequeue()
      {
        XCTAssertEqual(r, a[i], "Wrong object dequeued")
      }
    }
  }

  func QueuePerformanceTestFill<Q: QueueType>(_: Q.Type) where Q.Element == Thing
  {
    self.measure() {
      let q = Q()
      let element = Thing()
      for _ in 1...self.performanceTestIterations
      {
        q.enqueue(element)
      }

      for _ in 1...self.performanceTestIterations
      {
        _ = q.dequeue()
      }
    }
  }

  func QueuePerformanceTestSpin<Q: QueueType>(_: Q.Type) where Q.Element == Thing
  {
    self.measure() {
      let q = Q()
      let element = Thing()
      for _ in 1...self.performanceTestIterations
      {
        q.enqueue(element)
        _ = q.dequeue()
      }
    }
  }

  func QueuePerformanceTestEmpty<Q: QueueType>(_: Q.Type)
  {
    self.measure() {
      let q = Q()
      for _ in 1...self.performanceTestIterations
      {
        _ = q.dequeue()
      }
    }
  }

  func QueueInitEmptyTest<Q: QueueType>(_: Q.Type, newElement: Q.Element)
  {
    let q = Q(newElement)
    XCTAssertFalse(q.isEmpty)

    _ = q.dequeue()
    XCTAssertTrue(q.isEmpty)

    let enqueueCount = 10

    (1...enqueueCount).forEach { _ in q.enqueue(newElement) }
    let dequeueCount = q.reduce(0) { (i, _) in i+1 }

    XCTAssertEqual(dequeueCount, enqueueCount)
  }

  func MultiThreadedBenchmark<Q: QueueType>(_ type: Q.Type) where Q.Element: TestItem
  {
    let workers  = [3,5,7,11,19]
    let iterations = 1_000_000

    for threads in workers
    {
      let avg = MTBenchmark(type, threads: threads, iterations: iterations)
      print("\(threads):\t\(avg)")
    }
  }

  @discardableResult
  func MTBenchmark<Q: QueueType>(_: Q.Type, threads: Int, iterations: Int) -> Int where Q.Element: TestItem
  {
    guard threads > 0 else { return Int.max }

    var c = AtomicInt(0)

    let queue = Q(Q.Element())
    let start = mach_absolute_time()
    DispatchQueue.concurrentPerform(iterations: threads) {
      _ in
      while CAtomicsLoad(&c, .relaxed) < iterations
      {
        if (arc4random() & 1) == 1
        {
          queue.enqueue(Q.Element())
        }
        else
        {
          if let _ = queue.dequeue()
          {
            CAtomicsAdd(&c, 1, .relaxed)
          }
        }
      }
    }
    let dt = mach_absolute_time() - start
    return numericCast(dt)/numericCast(CAtomicsLoad(&c, .relaxed))
  }

  func QueuePerformanceTestMultiThreaded<Q: QueueType>(type: Q.Type) where Q.Element: TestItem
  {
    let producers = ProcessInfo.processInfo.activeProcessorCount - 1
    let iterations = 1_000_000/producers

    self.measure() {
      self.MultiThreadedSingleConsumerBenchmark(type, producers: 7, iterations: iterations)
    }
  }

  func MultiThreadedSingleConsumerBenchmark<Q: QueueType>(_ type: Q.Type, producers: Int, iterations: Int)
    where Q.Element: TestItem
  {
    let producers = ProcessInfo.processInfo.activeProcessorCount - 1
    let iterations = 1_000_000/producers

    let e = expectation(description: #function)
    let queue = Q(Q.Element())
//    let start = mach_absolute_time()
    DispatchQueue.global(qos: .userInitiated).async {
      var i: UInt64 = 0
      while i < (producers*iterations)
      {
        if let _ = queue.dequeue()
        {
          i += 1
        }
      }
//      let dt = mach_absolute_time() - start
//      print(dt/i)
      e.fulfill()
    }

    DispatchQueue.concurrentPerform(iterations: producers) {
      _ in
      for _ in 0..<iterations { queue.enqueue(Q.Element()) }
    }

    waitForExpectations(timeout: 5)
  }
}
