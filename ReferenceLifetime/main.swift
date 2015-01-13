//
//  main.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Foundation

public class Thing: Printable
{
  let id: Int

  init(_ i: Int)
  {
    id = i
    println("Thing \(self.id) was created")
  }

  convenience init()
  {
    self.init(Int(arc4random()))
  }

  public var description: String { return "A Thing labeled \(id)" }

  deinit
  {
    println("Thing \(self.id) has disappeared")
  }
}

var pq = ARCQueue<Thing>()

for i in 0..<3
{
  pq.enqueue(Thing(i))
}

for i in 3..<6
{
  pq.enqueue(Thing(i))
  pq.dequeue()
}

while let t = pq.dequeue()
{
  _ = t
}
