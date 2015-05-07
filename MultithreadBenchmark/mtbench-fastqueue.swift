//
//  File.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-05-06.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

import Dispatch

private func getQueue<T>(initialValue: T) -> FastQueue<T>
{
  return FastQueue(initialValue)
}

func FastQueueRunTest(workers: Int, run: Int = 1)
{
  if workers < 1 || run < 1 { return }

  var i: Int32 = 0

  let queue = getQueue(arc4random())

  let start = mach_absolute_time()
  dispatch_apply(workers, dispatch_get_global_queue(qos_class_self(), 0)) {
    _ in
    while i < iterations
    {
      if (random() & 1) == 0
      {
        for _ in 0...arc4random_uniform(numericCast(run+1))
        {
          queue.enqueue(arc4random())
        }
      }
      else
      {
        for _ in 0...arc4random_uniform(numericCast(run+1))
        {
          if let v = queue.dequeue()
          {
            OSAtomicIncrement32Barrier(&i)
          }
        }
      }
      OSMemoryBarrier()
    }
  }
  let dt = mach_absolute_time() - start
  println("\(workers):\t\(dt/numericCast(i))")
}
