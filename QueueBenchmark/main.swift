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
  _ = queue1.dequeue()
  queue1.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var queue1ref = Queue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = queue1ref.dequeue()
  queue1ref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("LinkQueue:")
var lqueue = LinkQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = lqueue.dequeue()
  lqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")


var lqueueref = LinkQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = lqueueref.dequeue()
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
  _ = fqueue.dequeue()
  fqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var fqueueref = FastQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = fqueueref.dequeue()
  fqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")

print("Two-Lock LinkQueue:")
var tllqueue = Link2LockQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = tllqueue.dequeue()
  tllqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var tllqueueref = Link2LockQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = tllqueueref.dequeue()
  tllqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")

print("Two-Lock FastQueue:")
var tlfqueue = Fast2LockQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = tlfqueue.dequeue()
  tlfqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var tlfqueueref = Fast2LockQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = tlfqueueref.dequeue()
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
  _ = losqueue.dequeue()
  losqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var losqueueref = LinkOSQueue(ref)
then = mach_absolute_time()
for _ in 1...iterations
{
  _ = losqueueref.dequeue()
  losqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("FastOSQueue:" )
var fosqueue = FastOSQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = fosqueue.dequeue()
  fosqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var fosqueueref = FastOSQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = fosqueueref.dequeue()
  fosqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("\nQueues without thread-safety")

print("UnsafeQueue:")
var unsafequeue = UnsafeQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = unsafequeue.dequeue()
  unsafequeue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var unsaferefqueue = UnsafeQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = unsaferefqueue.dequeue()
  unsaferefqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("ArrayQueue:")
var arrayqueue = ArrayQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = arrayqueue.dequeue()
  arrayqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var arrayrefqueue = ArrayQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = arrayrefqueue.dequeue()
  arrayrefqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("UnsafeLinkQueue:")
var ulinkqueue = UnsafeLinkQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = ulinkqueue.dequeue()
  ulinkqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var ureflinkqueue = UnsafeLinkQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = ureflinkqueue.dequeue()
  ureflinkqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("UnsafeFastQueue:" )
var ufastqueue = UnsafeFastQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = ufastqueue.dequeue()
  ufastqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var ureffastqueue = UnsafeFastQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = ureffastqueue.dequeue()
  ureffastqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")
