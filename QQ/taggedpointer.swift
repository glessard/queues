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

struct TaggedPointer<T>: Equatable
{
  private var value: Int64

  init()
  {
    value = 0
  }

  var isEmpty: Bool {
    return value == 0
  }

  @inline(__always) init(_ pointer: UnsafePointer<T>?, tag: Int64)
  {
    #if arch(x86_64) || arch(arm64)
      value = Int64(bitPattern: unsafeBitCast(pointer, to: UInt64.self) & 0x00ff_ffff_ffff_ffff + UInt64(bitPattern: tag) << 48)
    #else
      value = Int64(bitPattern: UInt64(unsafeBitCast(pointer, UInt32.self)) + UInt64(bitPattern: tag) << 32)
    #endif
  }

  @inline(__always) @discardableResult
  mutating func CAS(old: TaggedPointer, new: UnsafePointer<T>?) -> Bool
  {
    #if arch(x86_64) || arch(arm64)
      let oldtag = old.value >> 48
    #else // 32-bit architecture
      let oldtag = old.value >> 32
    #endif

    let nptr = TaggedPointer(new, tag: oldtag&+1)
    return OSAtomicCompareAndSwap64Barrier(old.value, nptr.value, &value)
  }

  var pointer: UnsafeMutablePointer<T>? {
    #if arch(x86_64) || arch(arm64)
      return UnsafeMutablePointer(bitPattern: UInt(value & 0x00ff_ffff_ffff_ffff))
    #else // 32-bit architecture
      return UnsafeMutablePointer(bitPattern: UInt(value & 0xffff_ffff))
    #endif
  }

  var pointee: T? {
    if let p = self.pointer
    {
      return p.pointee
    }
    return nil
  }

  var tag: Int64 {
    #if arch(x86_64) || arch(arm64)
      return Int64(bitPattern: UInt64(bitPattern: value) >> 48)
    #else // 32-bit architecture
      return Int64(bitPattern: UInt64(bitPattern: value) >> 32)
    #endif
  }

  static func ==<T>(lhs: TaggedPointer<T>, rhs: TaggedPointer<T>) -> Bool
  {
    return lhs.value == rhs.value
  }
}
