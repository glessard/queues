//
//  TaggedPointer.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-09-09.
//  Copyright © 2015 Guillaume Lessard. All rights reserved.
//

import Darwin

/// Int64 as tagged pointer, as a strategy to overcome the ABA problem in
/// synchronization algorithms based on atomic compare-and-swap operations.
///
/// The implementation uses Int64 as the base type in order to easily
/// work with OSAtomicCompareAndSwap in Swift.

@inline(__always) internal func TaggedPointer(pointer: UnsafePointer<Void>, tag: Int64) -> Int64
{
  #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
    return Int64(bitPattern: unsafeBitCast(pointer, UInt64.self) & 0x00ff_ffff_ffff_ffff + UInt64(bitPattern: tag) << 56)
  #else
    return Int64(bitPattern: UInt64(unsafeBitCast(pointer, UInt32.self)) + UInt64(bitPattern: tag) << 32)
  #endif
}

internal extension Int64
{
  @inline(__always) mutating func set(pointer: UnsafePointer<Void>, tag: Int64)
  {
    self = TaggedPointer(pointer, tag: tag)
  }

  @inline(__always) mutating func CAS(old old: Int64, new: UnsafePointer<Void>) -> Bool
  {
    if old != self { return false }

    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
      let oldtag = old >> 56
    #else // 32-bit architecture
      let oldtag = old >> 32
    #endif

    let nptr = TaggedPointer(new, tag: oldtag&+1)
    return OSAtomicCompareAndSwap64Barrier(old, nptr, &self)
  }

  var pointer: UnsafeMutablePointer<Void> {
    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
      return UnsafeMutablePointer(bitPattern: UInt(self & 0x00ff_ffff_ffff_ffff))
    #else // 32-bit architecture
      return UnsafeMutablePointer(bitPattern: UInt(self & 0xffff_ffff))
    #endif
  }

  var tag: Int64 {
    #if arch(x86_64) || arch(arm64) // speculatively in the case of arm64
      return Int64(bitPattern: UInt64(bitPattern: self) >> 56)
    #else // 32-bit architecture
      return Int64(bitPattern: UInt64(bitPattern: self) >> 32)
    #endif
  }
}
