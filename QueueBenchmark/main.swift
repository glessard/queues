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
var queue1 = ARCQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = queue1.dequeue()
  queue1.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var queue1ref = ARCQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = queue1ref.dequeue()
  queue1ref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("Pointer-Based Queue:")
var lqueue = Queue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = lqueue.dequeue()
  lqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")


var lqueueref = Queue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = lqueueref.dequeue()
  lqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("Node-recycling Queue:")
var fqueue = RecyclingQueue(iterations)
//fqueue.enqueue(42)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = fqueue.dequeue()
  fqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var fqueueref = RecyclingQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = fqueueref.dequeue()
  fqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")

print("Two-lock Queue:")
var tllqueue = TwoLockQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = tllqueue.dequeue()
  tllqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var tllqueueref = TwoLockQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = tllqueueref.dequeue()
  tllqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")

print("Two-lock Node-recycling Queue:")
var tlfqueue = TwoLockRecyclingQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = tlfqueue.dequeue()
  tlfqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var tlfqueueref = TwoLockRecyclingQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = tlfqueueref.dequeue()
  tlfqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("\nSwift combined with OSAtomicFifoQueue:")

print("OSQueue:" )
var losqueue = OSQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = losqueue.dequeue()
  losqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var losqueueref = OSQueue(ref)
then = mach_absolute_time()
for _ in 1...iterations
{
  _ = losqueueref.dequeue()
  losqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("RecyclingOSQueue:" )
var fosqueue = RecyclingOSQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = fosqueue.dequeue()
  fosqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var fosqueueref = RecyclingOSQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = fosqueueref.dequeue()
  fosqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("\nLock-free queues")

print("LockFreeLinkQueue (Michael-Scott Queue)")
var msqueue = LockFreeLinkQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = msqueue.dequeue()
  msqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

let msqueueref = LockFreeLinkQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = msqueueref.dequeue()
  msqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")

print("Lock-free MPSC queue (Vyukov)")
var mpscqueue = MPSCLinkQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = msqueue.dequeue()
  msqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

let mpscqueueref = MPSCLinkQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = msqueueref.dequeue()
  msqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")

print("Lock-free SPSC queue (Vyukov)")
var spscqueue = SPSCLinkQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = msqueue.dequeue()
  msqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

let spscqueueref = SPSCLinkQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = msqueueref.dequeue()
  msqueueref.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("\nQueues without thread-safety")

print("UnsafeARCQueue:")
var unsafequeue = UnsafeARCQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = unsafequeue.dequeue()
  unsafequeue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var unsaferefqueue = UnsafeARCQueue(ref)

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


print("UnsafeQueue:")
var ulinkqueue = UnsafeQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = ulinkqueue.dequeue()
  ulinkqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var ureflinkqueue = UnsafeQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = ureflinkqueue.dequeue()
  ureflinkqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")


print("Unsafe Recycling Queue:" )
var ufastqueue = UnsafeRecyclingQueue(iterations)

then = mach_absolute_time()
for i in 1...iterations
{
  _ = ufastqueue.dequeue()
  ufastqueue.enqueue(i)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration")

var ureffastqueue = UnsafeRecyclingQueue(ref)

then = mach_absolute_time()
for _ in 1...iterations
{
  _ = ureffastqueue.dequeue()
  ureffastqueue.enqueue(ref)
}
dt = mach_absolute_time() - then
print("\(dt/iterations) ns per iteration with references")
