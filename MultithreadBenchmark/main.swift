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

println("LinkQueue:")
t = 0
for w in workers
{
  t += LinkQueueRunTest(w)
}
println("Mean:\t\(t/workers.count)\n")

println("FastQueue:")
t = 0
for w in workers
{
  t += FastQueueRunTest(w)
}
println("Mean:\t\(t/workers.count)\n")
//println("FastQueue with runs:")
//for w in workers
//{
//  FastQueueRunTest(w, run: maximumRun)
//}

println("FastOSQueue:")
t = 0
for w in workers
{
  t += FastOSQueueRunTest(w)
}
println("Mean:\t\(t/workers.count)\n")

println("Double-Lock FastQueue:")
t = 0
for w in workers
{
  t += DoubleLockQueueRunTest(w)
}
println("Mean:\t\(t/workers.count)\n")
//println("Double-Lock FastQueue with runs:")
//for w in workers
//{
//  DoubleLockQueueRunTest(w, run: maximumRun)
//}

println("Lock-Free FastQueue:")
t = 0
for w in workers
{
  t += LockFreeQueueRunTest(w)
}
println("Mean:\t\(t/workers.count)\n")
//println("Lock-Free FastQueue with runs:")
//for w in workers
//{
//  LockFreeQueueRunTest(w, run: maximumRun)
//}

println("Optimistic FastQueue:")
t = 0
for w in workers
{
  t += OptimisticQueueRunTest(w)
}
println("Mean:\t\(t/workers.count)\n")
//println("Optimistic FastQueue with runs:")
//for w in workers
//{
//  OptimisticQueueRunTest(w, run: maximumRun)
//}
