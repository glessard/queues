//
//  main.swift
//  QueueBenchmark
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation

var iterations: UInt64 = 1_000_000
var then = mach_absolute_time()
var dt = mach_absolute_time() - then
let ref = Thing()

println("Swift-Only solutions")

println("Slow Queue:")
var queue1 = SlowQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  queue1.dequeue()
  queue1.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

var queue1ref = SlowQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  queue1ref.dequeue()
  queue1ref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with AnyObject references")


println("LinkQueue:")
var lqueue = LinkQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  lqueue.dequeue()
  lqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")


var lqueueref = LinkQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  lqueueref.dequeue()
  lqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with AnyObject references")


println("FastQueue:")
var fqueue = FastQueue(iterations)
//fqueue.enqueue(42)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueue.dequeue()
  fqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

var fqueueref = FastQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueueref.dequeue()
  fqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with AnyObject references")

println("Two-Lock FastQueue:")
var tlfqueue = Fast2LockQueue(iterations)
//tlfqueue.enqueue(42)

then = mach_absolute_time()
for i in 1...iterations
{
  tlfqueue.dequeue()
  tlfqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

var tlfqueueref = Fast2LockQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  tlfqueueref.dequeue()
  tlfqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with AnyObject references")

println("Michael&Scott Lock-Free FastQueue:")
var lffqueue = LockFreeFastQueue(iterations)
then = mach_absolute_time()
for i in 1...iterations
{
  lffqueue.dequeue()
  lffqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

var lffqueueref = LockFreeFastQueue(ref)
then = mach_absolute_time()
for i in 1...iterations
{
  lffqueueref.dequeue()
  lffqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with AnyObject references")


println("Optimistic Lock-Free FastQueue:")
var ofqueue = OptimisticFastQueue(iterations)
then = mach_absolute_time()
for i in 1...iterations
{
  ofqueue.dequeue()
  ofqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

var ofqueueref = OptimisticFastQueue(ref)
then = mach_absolute_time()
for i in 1...iterations
{
  ofqueueref.dequeue()
  ofqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with AnyObject references")


println()
println("AnyObject queues")

println("RefARCQueue")
var srqueue = RefARCQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  srqueue.dequeue()
  srqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with AnyObject references")


println()
println("Swift with OSAtomicFifoQueue:")

println("LinkOSQueue:" )
var losqueue = LinkOSQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  losqueue.dequeue()
  losqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

var losqueueref = LinkOSQueue(ref)
then = mach_absolute_time()
for i in 1...iterations
{
  losqueueref.dequeue()
  losqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with AnyObject references")


println("FastOSQueue:" )
var fosqueue = FastOSQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  fosqueue.dequeue()
  fosqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

var fosqueueref = FastOSQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  fosqueueref.dequeue()
  fosqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with AnyObject references")


println()
println("nongeneric queues")

println("IntQueue:" )
var intqueue = IntQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  intqueue.dequeue()
  intqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

println("IntOSQueue:" )
var intosqueue = IntOSQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  intosqueue.dequeue()
  intosqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

println("IntUnsafeQueue:" )
var intunsafequeue = IntUnsafeQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  intunsafequeue.dequeue()
  intunsafequeue.enqueue(i)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration")

println("ThingQueue:" )
var semqueue = ThingQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  semqueue.dequeue()
  semqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with Thing references")

println("ThingOSQueue:" )
var semosqueue = ThingOSQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  semosqueue.dequeue()
  semosqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per iteration with Thing references")

println("ThingUnsafeQueue:" )
var unsafequeue = ThingUnsafeQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  unsafequeue.dequeue()
  unsafequeue.enqueue(ref)
}
dt = mach_absolute_time() - then
print(dt/iterations); println(" ns per thread-unsafe iteration with Thing references")
