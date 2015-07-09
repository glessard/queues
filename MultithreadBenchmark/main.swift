//
//  main.swift
//  MultithreadBenchmark
//
//  Created by Guillaume Lessard on 2015-05-06.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

let iterations: Int32 = 5_000_000
let workers = [3,5,7,11,19]
let maximumRun = 100
var t = 0

print("LinkQueue:")
t = 0
for w in workers
{
  t += LinkQueueRunTest(w)
}
print("Mean:\t\(t/workers.count)\n")

print("FastQueue:")
t = 0
for w in workers
{
  t += FastQueueRunTest(w)
}
print("Mean:\t\(t/workers.count)\n")
//println("FastQueue with runs:")
//for w in workers
//{
//  FastQueueRunTest(w, run: maximumRun)
//}

print("LinkOSQueue:")
t = 0
for w in workers
{
  t += LinkOSQueueRunTest(w)
}
print("Mean:\t\(t/workers.count)\n")

print("FastOSQueue:")
t = 0
for w in workers
{
  t += FastOSQueueRunTest(w)
}
print("Mean:\t\(t/workers.count)\n")

print("Double-Lock LinkQueue:")
t = 0
for w in workers
{
  t += DoubleLockLinkQueueRunTest(w)
}
print("Mean:\t\(t/workers.count)\n")

print("Double-Lock FastQueue:")
t = 0
for w in workers
{
  t += DoubleLockFastQueueRunTest(w)
}
print("Mean:\t\(t/workers.count)\n")
//println("Double-Lock FastQueue with runs:")
//for w in workers
//{
//  DoubleLockQueueRunTest(w, run: maximumRun)
//}

//print("Lock-Free LinkQueue:")
//t = 0
//for w in workers
//{
//  t += LockFreeLinkQueueRunTest(w)
//}
//print("Mean:\t\(t/workers.count)\n")
//println("Lock-Free FastQueue with runs:")
//for w in workers
//{
//  LockFreeLinkQueueRunTest(w, run: maximumRun)
//}

print("Lock-Free FastQueue:")
t = 0
for w in workers
{
  t += LockFreeFastQueueRunTest(w)
}
print("Mean:\t\(t/workers.count)\n")
//println("Lock-Free FastQueue with runs:")
//for w in workers
//{
//  LockFreeFastQueueRunTest(w, run: maximumRun)
//}

//print("Optimistic LinkQueue:")
//t = 0
//for w in workers
//{
//  t += OptimisticLinkQueueRunTest(w)
//}
//print("Mean:\t\(t/workers.count)\n")
//println("Optimistic FastQueue with runs:")
//for w in workers
//{
//  OptimisticLinkQueueRunTest(w, run: maximumRun)
//}

print("Optimistic FastQueue:")
t = 0
for w in workers
{
  t += OptimisticFastQueueRunTest(w)
}
print("Mean:\t\(t/workers.count)\n")
//println("Optimistic FastQueue with runs:")
//for w in workers
//{
//  OptimisticFastQueueRunTest(w, run: maximumRun)
//}
