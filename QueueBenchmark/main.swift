//
//  main.swift
//  QueueBenchmark
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.Mach

var iterations: UInt64 = 1_000_000
var then = mach_absolute_time()
var dt = mach_absolute_time() - then
let ref = Thing()

print("Thread-safe, pure-Swift queues")

print("ARC Queue:")
var queue1 = Queue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  queue1.dequeue()
  queue1.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var queue1ref = Queue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  queue1ref.dequeue()
  queue1ref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("LinkQueue:")
var lqueue = LinkQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  lqueue.dequeue()
  lqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")


var lqueueref = LinkQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  lqueueref.dequeue()
  lqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("FastQueue:")
var fqueue = FastQueue(iterations)
//fqueue.enqueue(42)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueue.dequeue()
  fqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var fqueueref = FastQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  fqueueref.dequeue()
  fqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")

print("Two-Lock LinkQueue:")
var tllqueue = Link2LockQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  tllqueue.dequeue()
  tllqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var tllqueueref = Link2LockQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  tllqueueref.dequeue()
  tllqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")

print("Two-Lock FastQueue:")
var tlfqueue = Fast2LockQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  tlfqueue.dequeue()
  tlfqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var tlfqueueref = Fast2LockQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  tlfqueueref.dequeue()
  tlfqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("\nSwift combined with OSAtomicFifoQueue:")

print("LinkOSQueue:" )
var losqueue = LinkOSQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  losqueue.dequeue()
  losqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var losqueueref = LinkOSQueue(ref)
then = mach_absolute_time()
for i in 1...iterations
{
  losqueueref.dequeue()
  losqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("FastOSQueue:" )
var fosqueue = FastOSQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  fosqueue.dequeue()
  fosqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var fosqueueref = FastOSQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  fosqueueref.dequeue()
  fosqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("\nQueues without thread-safety")

print("UnsafeQueue:")
var uqueue = UnsafeQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  uqueue.dequeue()
  uqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var urefqueue = UnsafeQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  urefqueue.dequeue()
  urefqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("UnsafeFastQueue:" )
var unsafequeue = UnsafeFastQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  unsafequeue.dequeue()
  unsafequeue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var unsaferefqueue = UnsafeFastQueue(ref)

then = mach_absolute_time()
for i in 1...iterations
{
  unsaferefqueue.dequeue()
  unsaferefqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")
