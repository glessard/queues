//
//  main.swift
//  MultithreadBenchmark
//
//  Created by Guillaume Lessard on 2015-05-06.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

let iterations: Int32 = 1_000_000
let workers = [1,2,4,7,11,19,31]
let maximumRun = 100

//println("SlowQueue:")
//for w in workers
//{
//  SlowQueueRunTest(w)
//}

//println("FastQueue:")
//for w in workers
//{
//  FastQueueRunTest(w)
//}
//println("FastQueue with runs:")
//for w in workers
//{
//  FastQueueRunTest(w, run: maximumRun)
//}

//println("Double-Lock FastQueue:")
//for w in workers
//{
//  DoubleLockQueueRunTest(w)
//}
//println("Double-Lock FastQueue with runs:")
//for w in workers
//{
//  DoubleLockQueueRunTest(w, run: maximumRun)
//}

println("Lock-Free FastQueue:")
for w in workers
{
  LockFreeQueueRunTest(w)
}
//println("Lock-Free FastQueue with runs:")
//for w in workers
//{
//  LockFreeQueueRunTest(w, run: maximumRun)
//}

println("Optimistic FastQueue:")
for w in workers
{
  OptimisticQueueRunTest(w)
}
//println("Optimistic FastQueue with runs:")
//for w in workers
//{
//  OptimisticQueueRunTest(w, run: maximumRun)
//}
