//
//  better-atomics.swift
//  Test23
//
//  Created by Guillaume Lessard on 2015-05-21.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

import Darwin.libkern.OSAtomic

@inline(__always) func CAS<T>(o: UnsafeMutablePointer<T>, n: UnsafeMutablePointer<T>,
                              p: UnsafeMutablePointer<UnsafeMutablePointer<T>>) -> Bool
{
  return OSAtomicCompareAndSwapPtrBarrier(o, n, UnsafeMutablePointer(p))
}

@inline(__always) func CAS<T>(o: UnsafePointer<T>, n: UnsafePointer<T>,
                              p: UnsafeMutablePointer<UnsafePointer<T>>) -> Bool
{
  return OSAtomicCompareAndSwapPtrBarrier(UnsafeMutablePointer(o), UnsafeMutablePointer(n), UnsafeMutablePointer(p))
}

@inline(__always) func CAS(o: Int, n: Int, p: UnsafeMutablePointer<Int>) -> Bool
{
  return OSAtomicCompareAndSwapLongBarrier(o, n, p)
}

@inline(__always) func CAS(o: UInt, n: UInt, p: UnsafeMutablePointer<UInt>) -> Bool
{
  return OSAtomicCompareAndSwapLongBarrier(unsafeBitCast(o, Int.self), unsafeBitCast(n, Int.self), UnsafeMutablePointer(p))
}

@inline(__always) func CAS(o: Int32, n: Int32, p: UnsafeMutablePointer<Int32>) -> Bool
{
  return OSAtomicCompareAndSwap32Barrier(o, n, p)
}

@inline(__always) func CAS(o: UInt32, n: UInt32, p: UnsafeMutablePointer<UInt32>) -> Bool
{
  return OSAtomicCompareAndSwap32Barrier(unsafeBitCast(o, Int32.self), unsafeBitCast(n, Int32.self), UnsafeMutablePointer(p))
}

@inline(__always) func CAS(o: Int64, n: Int64, p: UnsafeMutablePointer<Int64>) -> Bool
{
  return OSAtomicCompareAndSwap64Barrier(o, n, p)
}

@inline(__always) func CAS(o: UInt64, n: UInt64, p: UnsafeMutablePointer<UInt64>) -> Bool
{
  return OSAtomicCompareAndSwap64Barrier(unsafeBitCast(o, Int64.self), unsafeBitCast(n, Int64.self), UnsafeMutablePointer(p))
}
