//
//  main.swift
//  dqtest
//
//  Created by Guillaume Lessard on 2015-01-03.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

import Darwin

let iterations = UInt64(100_000)
let head = AtomicQueueInit()
let offset = RefNodeLinkOffset()

var start = mach_absolute_time()
for i in 1...iterations
{
  if OSAtomicFifoDequeue(head, offset) != nil
  {
    _ = UnsafeMutablePointer<()>.null()
  }
}
var dt = mach_absolute_time() - start
println("\(dt) \(dt/iterations)")

var size: Int32 = 0
start = mach_absolute_time()
for i in 1...iterations
{
  OSAtomicIncrement32Barrier(&size)
  OSAtomicDecrement32Barrier(&size)
}
dt = mach_absolute_time() - start
println("\(dt) \(dt/iterations)")

let pool = AtomicQueueInit()
start = mach_absolute_time()
for i in 1...iterations
{
  if let zip: AnyObject = RefNodeDequeue2(head, pool)
  {
    _ = zip
  }
}
dt = mach_absolute_time() - start
println("\(dt) \(dt/iterations)")

start = mach_absolute_time()
for i in 1...iterations
{
  if let zip: AnyObject = RefNodeDequeue(head)
  {
    _ = zip
  }
}
dt = mach_absolute_time() - start
println("\(dt) \(dt/iterations)")


var q = PointerQueue4<Int>(0)
println(q.CountNodes())
q.enqueue(q.CountNodes())
println(q.CountNodes())
