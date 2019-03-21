//
//  main.swift
//  QueueBenchmark
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin.Mach

let iterations: UInt64 = 1_000_000
var then = mach_absolute_time()
func measure<Q: QueueType>(_ q: Q) -> UInt64
{
  let start = mach_absolute_time()
  var i = 0
  while let element = q.dequeue(), i < iterations
  {
    q.enqueue(element)
    i += 1
  }
  return mach_absolute_time() - start
}

func measure<Q: QueueType>(_ q: Q) -> UInt64
  where Q.Element == UInt64
{
  let start = mach_absolute_time()
  while let i = q.dequeue(), i > 0
  {
    q.enqueue(i-1)
  }
  return mach_absolute_time() - start
}

let ref = Thing()
var dt: UInt64 = 0

print("Thread-safe, pure-Swift queues")

print("ARC Queue:")
dt = measure(ARCQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(ARCQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("Pointer-Based Queue:")
dt = measure(Queue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(Queue(ref))
print("\(dt/iterations) ns per iteration with references")


print("Node-recycling Queue:")
dt = measure(RecyclingQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(RecyclingQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("Two-lock Queue:")
dt = measure(TwoLockQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(TwoLockQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("Two-lock Node-recycling Queue:")
dt = measure(TwoLockRecyclingQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(TwoLockRecyclingQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("\nSwift combined with OSAtomicFifoQueue:")

print("OSQueue:" )
dt = measure(OSQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(OSQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("RecyclingOSQueue:" )
dt = measure(RecyclingOSQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(RecyclingOSQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("\nLock-free queues")

print("Michael-Scott Lock-Free Queue")
dt = measure(LockFreeQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(LockFreeReferenceQueue(ref))
print("\(dt/iterations) ns per iteration with references")

print("Lock-free MPSC queue (Vyukov)")
dt = measure(MPSCLockFreeQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(MPSCLockFreeQueue(ref))
print("\(dt/iterations) ns per iteration with references")

print("Lock-free SPSC queue (Vyukov)")
dt = measure(SPSCLockFreeQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(SPSCLockFreeQueue(ref))
print("\(dt/iterations) ns per iteration with references")

print("Lock-free SPSC queue with node recycling (Vyukov)")
dt = measure(SPSCLockFreeRecyclingQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(SPSCLockFreeRecyclingQueue(ref))
print("\(dt/iterations) ns per iteration with references")

print("Single-Consumer Optimistic Queue")
dt = measure(SingleConsumerOptimisticQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(SingleConsumerOptimisticQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("\nQueues without thread-safety")

print("UnsafeARCQueue:")
dt = measure(UnsafeARCQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(UnsafeARCQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("ArrayQueue:")
dt = measure(ArrayQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(ArrayQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("UnsafeQueue:")
dt = measure(UnsafeQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(UnsafeQueue(ref))
print("\(dt/iterations) ns per iteration with references")


print("Unsafe Recycling Queue:" )
dt = measure(UnsafeRecyclingQueue(iterations))
print("\(dt/iterations) ns per iteration")

dt = measure(UnsafeRecyclingQueue(ref))
print("\(dt/iterations) ns per iteration with references")
