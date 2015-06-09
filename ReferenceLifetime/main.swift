  //
//  main.swift
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-13.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

import Darwin

var start = mach_absolute_time()
var dt = start
dt = 10_000_000
let iterations = dt

var a = 1 as UInt
var counter = 0 as UInt

start = mach_absolute_time()
for _ in 1...iterations
{
  counter = counter + a
}
dt = mach_absolute_time() - start
print(dt)

counter = 0
start = mach_absolute_time()
for _ in 1...iterations
{
  counter = counter &+ a
}
dt = mach_absolute_time() - start
print(dt)

counter = 0
start = mach_absolute_time()
for _ in 1...iterations
{
  counter = (counter + a) & 0x7fff_ffff_ffff_ffff
}
dt = mach_absolute_time() - start
print(dt)
