//
//  TaggedPointer.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-09-09.
//  Copyright © 2015 Guillaume Lessard. All rights reserved.
//

import CAtomics

/// UInt64 as tagged pointer, as a strategy to overcome the ABA problem in
/// synchronization algorithms based on atomic compare-and-swap operations.

struct AtomicTP<T: OSAtomicNode>
{
  private var atom = AtomicUInt64()

  init()
  {
    atom.initialize(0)
  }

  @inline(__always)
  mutating func store(_ p: TaggedPointer<T>)
  {
    atom.store(p.int, .sequential)
  }

  @inline(__always)
  mutating func initialize()
  {
    atom.store(0, .relaxed)
  }

  @inline(__always)
  mutating func load() -> TaggedPointer<T>
  {
    let value = atom.load(.sequential)
    return TaggedPointer(rawValue: value)
  }

  @inline(__always)
  mutating func CAS(old: TaggedPointer<T>, new: T) -> Bool
  {
    let new = TaggedPointer(new, incrementingTag: old)
    return atom.CAS(old.int, new.int, .strong, .sequential)
  }
}

struct TaggedPointer<T: OSAtomicNode>: Equatable
{
  private var value: UInt64

  fileprivate var int: UInt64 { return value }

  fileprivate init(rawValue: UInt64)
  {
    value = rawValue
  }

  init(_ node: T)
  {
    self.init(node, tag: 1)
  }

  init(_ node: T, usingTag other: TaggedPointer)
  {
    self.init(node, tag: other.tag)
  }

  init(_ node: T, incrementingTag old: TaggedPointer)
  {
    self.init(node, tag: old.tag&+1)
  }

  init(_ node: T, tag: UInt64)
  {
    #if arch(x86_64) || arch(arm64)
      value = UInt64(UInt(bitPattern: node.storage)) + (tag & 0x7fff) << 48
    #else
      value = UInt64(UInt(bitPattern: node.storage)) + (tag & 0x7fff) << 32
    #endif
  }

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
