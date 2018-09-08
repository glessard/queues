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

struct AtomicTP<Node: OSAtomicNode>
{
  private var atom = AtomicUInt64()

  init()
  {
    atom.initialize(0)
  }

  @inline(__always)
  mutating func store(_ p: TaggedPointer<Node>)
  {
    atom.store(p.int, .sequential)
  }

  @inline(__always)
  mutating func initialize()
  {
    atom.store(0, .relaxed)
  }

  @inline(__always)
  mutating func load() -> TaggedPointer<Node>?
  {
    let value = atom.load(.sequential)
    return TaggedPointer(rawValue: value)
  }

  @inline(__always)
  mutating func CAS(old: TaggedPointer<Node>?, new: Node) -> Bool
  {
    if let old = old
    {
      let new = TaggedPointer(new, incrementingTag: old)
      return atom.CAS(old.int, new.int, .strong, .sequential)
    }
    else
    {
      let new = TaggedPointer(new)
      return atom.CAS(0, new.int, .strong, .sequential)
    }
  }
}

struct TaggedPointer<Node: OSAtomicNode>: Equatable
{
  private var value: UInt64

  fileprivate var int: UInt64 { return value }

  fileprivate init?(rawValue: UInt64)
  {
    if rawValue == 0 { return nil }
    value = rawValue
  }

  init(_ node: Node)
  {
    self.init(node, tag: 1)
  }

  init(_ node: Node, usingTag other: TaggedPointer)
  {
    self.init(node, tag: other.tag)
  }

  init(_ node: Node, incrementingTag old: TaggedPointer)
  {
    self.init(node, tag: old.tag&+1)
  }

  init(_ node: Node, tag: UInt64)
  {
    #if arch(x86_64) || arch(arm64)
      value = UInt64(UInt(bitPattern: node.storage)) + (tag & 0x7fff) << 48
    #else
      value = UInt64(UInt(bitPattern: node.storage)) + (tag & 0x7fff) << 32
    #endif
  }

  var pointer: UnsafeMutableRawPointer {
    #if arch(x86_64) || arch(arm64)
      return UnsafeMutableRawPointer(bitPattern: UInt(value & 0x0000_ffff_ffff_ffff))!
    #else // 32-bit architecture
      return UnsafeMutableRawPointer(bitPattern: UInt(value & 0xffff_ffff))!
    #endif
  }

  var node: Node {
    return Node(storage: self.pointer)
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
