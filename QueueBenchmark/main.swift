//
//  main.swift
//  QueueBenchmark
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation

var iterations: UInt64 = 10_000
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
var fqueues = FastQueueStruct(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueues.dequeue()
  fqueues.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println()
println("iOS-compatible hybrid solutions")

println("FastQueue (with pool):")
var fqueuep = FastPoolQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueuep.dequeue()
  fqueuep.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("FastQueue (as struct with pool):")
var fqueueps = FastPoolQueueStruct(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueueps.dequeue()
  fqueueps.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println()
println("Swift + C solutions")


println("RefQueueC1:")
var rqueue1 = RefQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  rqueue1.dequeue()
  rqueue1.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefQueueC2:")
var rqueue2 = RefQueueC2(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  rqueue2.dequeue()
  rqueue2.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefQueueC3:")
var rqueue3 = RefQueueC3(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  rqueue3.dequeue()
  rqueue3.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefQueueC-Struct:")
var rqueue4 = RefQueueStruct(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  rqueue4.dequeue()
  rqueue4.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefDoubleQueue (RefQueue with Pool):")
var rqueue2x = RefDoubleQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  rqueue2x.dequeue()
  rqueue2x.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("RefDoubleQueueStruct (RefQueue with Pool as Struct):")
var rqueue2s = RefDoubleQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  rqueue2s.dequeue()
  rqueue2s.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("BoxQueue:")
var bqueue = BoxQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  bqueue.dequeue()
  bqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


println("PointerQueue (with C helpers):" )
var pqueuec = PointerQueueWithC(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  pqueuec.dequeue()
  pqueuec.enqueue(i)
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


println("PointerQueue (pure Swift, as struct, with pool, Swift node):" )
var pqueue4 = PointerQueue4(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  pqueue4.dequeue()
  pqueue4.enqueue(i)
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
