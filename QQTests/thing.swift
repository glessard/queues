//
//  thing.swift
//  QQTests
//
//  Created by Guillaume Lessard on 2015-01-12.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

import func Darwin.C.stdlib.arc4random

protocol TestItem
{
  var id: UInt32 { get }
  init()
}

class Thing: TestItem
{
  let id = arc4random()
  required init() { }
}

struct Datum: TestItem
{
  let id = arc4random()
  init() { }
}
