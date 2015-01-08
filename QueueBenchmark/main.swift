//
//  main.swift
//  QueueBenchmark
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation

var iterations: UInt64 = 100_000
var then = mach_absolute_time()
var dt = mach_absolute_time() - then
let ref = dispatch_semaphore_create(1)!

println("Swift-Only solutions")

println("Queue:")
var queue = Queue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  queue.dequeue()
  queue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("FastQueue:")
var fqueue = FastQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueue.dequeue()
  fqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("FastQueue (as struct):")
var fqueuess = FastQueueStruct(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueuess.dequeue()
  fqueuess.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println()
println("iOS-compatible hybrid solutions")

println("FastQueue (with pool):")
var fqueuep = FastQueuePool(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueuep.dequeue()
  fqueuep.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("FastQueue (as struct with pool):")
var fqueueps = FastQueuePoolStruct(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueueps.dequeue()
  fqueueps.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("AnyQueue (as struct with pool):")
var aqueueps = AnyQueuePoolStruct(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  aqueueps.dequeue()
  aqueueps.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println()
println("Swift with OSAtomicFifoQueue:")

println("PointerQueue (pure Swift):" )
var pqueue1 = PointerQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  pqueue1.dequeue()
  pqueue1.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("PointerQueue (pure Swift, as struct):" )
var pqueue2 = PointerQueue2(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  pqueue2.dequeue()
  pqueue2.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("PointerQueue (pure Swift, as struct, with pool):" )
var pqueue3 = PointerQueue3(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  pqueue3.dequeue()
  pqueue3.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefQueue (pure Swift):" )
var squeue1 = RefQueueSwift1(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  squeue1.dequeue()
  squeue1.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefQueue (pure Swift 2):" )
var squeue2 = RefQueueSwift2(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  squeue2.dequeue()
  squeue2.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefQueue (pure Swift 3):" )
var squeue3 = RefQueueSwift3(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  squeue3.dequeue()
  squeue3.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefQueue (pure Swift 2, with pool):" )
var squeue2p = RefQueuePool(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  squeue2p.dequeue()
  squeue2p.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefQueue (pure Swift 2, as struct):" )
var squeue2s = RefQueueStruct(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  squeue2s.dequeue()
  squeue2s.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefQueue (pure Swift 2, as struct with pool):" )
var squeue2ps = RefQueuePoolStruct(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  squeue2ps.dequeue()
  squeue2ps.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println()
println("PointerQueue with Reference (pure Swift, as struct, with pool, Swift node):" )
var pqueueref = PointerQueue3(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  pqueueref.dequeue()
  pqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

println()
println("FastQueue with Reference (pure Swift, as struct, with pool, Swift node):" )
var fqueueref = FastQueuePoolStruct(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueueref.dequeue()
  fqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")
