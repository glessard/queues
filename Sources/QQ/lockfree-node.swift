//
//  lockfree-node.swift
//  QQ
//
//  Created by Guillaume Lessard on 06/09/2016.
//  Copyright © 2016 Guillaume Lessard. All rights reserved.
//

import CAtomics

private struct LockFreeNodeData
{
  var prev: TaggedMutableRawPointer
  var next: AtomicTaggedOptionalMutableRawPointer
  var data: AtomicOptionalMutableRawPointer
}

private let prevOffset = MemoryLayout.offset(of: \LockFreeNodeData.prev)!
private let nextOffset = MemoryLayout.offset(of: \LockFreeNodeData.next)!
private let dataOffset = MemoryLayout.offset(of: \LockFreeNodeData.data)!

private let nullNode = TaggedOptionalMutableRawPointer(nil, tag: 0)

struct LockFreeNode: OSAtomicNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  init?(storage: UnsafeMutableRawPointer?)
  {
    guard let storage = storage else { return nil }
    self.storage = storage
  }

  private init(pointer: UnsafeMutableRawPointer? = nil)
  {
    storage = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<LockFreeNodeData>.size,
                                               alignment: MemoryLayout<LockFreeNodeData>.alignment)
    (storage+prevOffset).bindMemory(to: TaggedMutableRawPointer.self, capacity: 1)
    prev = TaggedMutableRawPointer()
    (storage+nextOffset).bindMemory(to: AtomicTaggedOptionalMutableRawPointer.self, capacity: 1)
    CAtomicsInitialize(next, nullNode)
    (storage+dataOffset).bindMemory(to: AtomicOptionalMutableRawPointer.self, capacity: 1)
    CAtomicsInitialize(data, pointer)
  }

  static var dummy: LockFreeNode { return LockFreeNode() }

  init(initializedWith element: UnsafeMutableRawPointer)
  {
    self.init(pointer: element)
  }

  func deallocate()
  {
    storage.deallocate()
  }

  var prev: TaggedMutableRawPointer {
    @inlinable unsafeAddress {
      return UnsafeRawPointer(storage+prevOffset).assumingMemoryBound(to: TaggedMutableRawPointer.self)
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+prevOffset).assumingMemoryBound(to: TaggedMutableRawPointer.self)
    }
  }

  var next: UnsafeMutablePointer<AtomicTaggedOptionalMutableRawPointer> {
    @inlinable get {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
    }
  }

  var data: UnsafeMutablePointer<AtomicOptionalMutableRawPointer> {
    @inlinable get {
      return (storage+dataOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  func initialize(to element: UnsafeMutableRawPointer)
  {
    CAtomicsStore(next, nullNode, .relaxed)
    CAtomicsStore(data, element, .release)
  }
}
