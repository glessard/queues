//
//  TaggedPointer.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-09-09.
//  Copyright © 2015 Guillaume Lessard. All rights reserved.
//

import CAtomics

/// Int64 as tagged pointer, as a strategy to overcome the ABA problem in
/// synchronization algorithms based on atomic compare-and-swap operations.
///
/// The implementation uses Int64 as the base type in order to easily
/// work with OSAtomicCompareAndSwap in Swift.

struct AtomicTP<T: OSAtomicNode>
{
  @_versioned internal var atom: CAtomicsUInt64

  init()
  {
    atom = CAtomicsUInt64()
    CAtomicsUInt64Init(0, &atom)
  }

  @inline(__always)
  mutating func store(_ p: TaggedPointer<T>)
  {
    CAtomicsUInt64Store(p.int, &atom, .sequential)
  }

  @inline(__always)
  mutating func initialize()
  {
    CAtomicsUInt64Store(0, &atom, .relaxed)
  }

  @inline(__always)
  mutating func load() -> TaggedPointer<T>
  {
    let value = CAtomicsUInt64Load(&atom, .sequential)
    return TaggedPointer(rawValue: value)
  }

  @inline(__always)
  mutating func CAS(old: TaggedPointer<T>, new: T) -> Bool
  {
    let new = TaggedPointer(new, updatingTagFrom: old).int
    var old = old.int
    return CAtomicsUInt64StrongCAS(&old, new, &atom, .sequential, .relaxed)
  }
}

struct TaggedPointer<T: OSAtomicNode>: Equatable
{
  private var value: UInt64

  @_versioned internal var int: UInt64 { return value }

//  init()
//  {
//    value = 0
//  }

  @_versioned internal init(rawValue: UInt64)
  {
    value = rawValue
  }

  init(_ node: T, updatingTagFrom old: TaggedPointer)
  {
    self.init(node, tag: old.tag&+1)
  }

  init(_ node: T, tag: UInt64)
  {
    #if arch(x86_64) || arch(arm64)
      value = UInt64(UInt(bitPattern: node.storage)) & 0x0000_ffff_ffff_ffff + tag << 48
    #else
      value = UInt64(unsafeBitCast(pointer, UInt32.self)) + tag << 32
    #endif
  }

//  var isEmpty: Bool {
//    return value == 0
//  }

  var pointer: UnsafeMutableRawPointer? {
    #if arch(x86_64) || arch(arm64)
      return UnsafeMutableRawPointer(bitPattern: UInt(value & 0x0000_ffff_ffff_ffff))
    #else // 32-bit architecture
      return UnsafeMutableRawPointer(bitPattern: UInt(value & 0xffff_ffff))
    #endif
  }

  var pointee: T? {
    if let bytes = self.pointer
    {
      return T(storage: bytes)
    }
    return nil
  }

  var tag: UInt64 {
    #if arch(x86_64) || arch(arm64)
      return (value >> 48)
    #else // 32-bit architecture
      return (value >> 32)
    #endif
  }

  static func ==<T>(lhs: TaggedPointer<T>, rhs: TaggedPointer<T>) -> Bool
  {
    return lhs.value == rhs.value
  }
}
