//
//  File.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-05-06.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

import Dispatch

private func getQueue<T>(initialValue: T) -> LockFreeFastQueue<T>
{
  return LockFreeFastQueue(initialValue)
}

func LockFreeQueueRunTest(workers: Int, run: Int = 0) -> Int
{
  if workers < 1 { return Int.max }

  var i: Int32 = 0

  let queue = getQueue(arc4random())

  let start = mach_absolute_time()
  dispatch_apply(workers, dispatch_get_global_queue(qos_class_self(), 0)) {
    _ in
    while i < iterations
    {
      if (random() & 1) == 0
      {
        for _ in 0...arc4random_uniform(numericCast(run))
        {
          queue.enqueue(arc4random())
        }
      }
      else
      {
        for _ in 0...arc4random_uniform(numericCast(run))
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
  return numericCast(dt)/numericCast(i)
}
