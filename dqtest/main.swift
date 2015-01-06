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
  if OSAtomicFifoDequeue(head, offset) != UnsafeMutablePointer.null()
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


private let poffset = PointerNodeLinkOffset()
private let plength = PointerNodeSize()

start = mach_absolute_time()
for i in 1...iterations
{
  let node = UnsafeMutablePointer<PointerNode>(malloc(plength))
  node.memory.next = UnsafeMutablePointer.null()
  OSAtomicEnqueue(pool, node, 0)
  let dqed = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
  free(dqed)
}
dt = mach_absolute_time() - start
println("\(dt) \(dt/iterations)")

start = mach_absolute_time()
for i in 1...iterations
{
  let node = UnsafeMutablePointer<PointerNode>.alloc(1)
  node.memory.next = UnsafeMutablePointer.null()
  OSAtomicEnqueue(pool, node, 0)
  let dqed = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
  dqed.dealloc(1)
}
dt = mach_absolute_time() - start
println("\(dt) \(dt/iterations)")


var node = UnsafeMutablePointer<PointerNode>.null()
var n = UnsafeMutablePointer<PointerNode>.alloc(1)
n.initialize(PointerNode(next: nil, item: &node))
start = mach_absolute_time()
for i in 1...iterations
{
  if node == nil
  {
    OSAtomicEnqueue(pool, n, 0)
    node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
    node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
  }
}
dt = mach_absolute_time() - start
println("\(dt) \(dt/iterations)")

start = mach_absolute_time()
for i in 1...iterations
{
  if node == UnsafeMutablePointer.null()
  {
    OSAtomicEnqueue(pool, n, 0)
    node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
    node = UnsafeMutablePointer<PointerNode>(OSAtomicDequeue(pool, 0))
  }
}
dt = mach_absolute_time() - start
println("\(dt) \(dt/iterations)")
