//
//  lockfree-node.swift
//  QQ
//
//  Created by Guillaume Lessard on 06/09/2016.
//  Copyright © 2016 Guillaume Lessard. All rights reserved.
//

import CAtomics

private let prevOffset = 0
private let nextOffset = prevOffset + MemoryLayout<TaggedMutableRawPointer>.stride
private let linkOffset = nextOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride
private let dataOffset = linkOffset + MemoryLayout<UnsafeMutableRawPointer?>.stride

private let nullNode = TaggedOptionalMutableRawPointer(nil, tag: 0)

struct LockFreeNode: OSAtomicNode, StackNode, Equatable
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
    storage = UnsafeMutableRawPointer.allocate(byteCount: dataOffset + MemoryLayout<AtomicOptionalMutableRawPointer>.stride,
                                               alignment: MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.alignment)
    (storage+prevOffset).bindMemory(to: TaggedMutableRawPointer.self, capacity: 1)
    prev = TaggedMutableRawPointer()
    (storage+nextOffset).bindMemory(to: AtomicTaggedOptionalMutableRawPointer.self, capacity: 1)
    next = AtomicTaggedOptionalMutableRawPointer(nullNode)
    (storage+linkOffset).bindMemory(to: UnsafeMutableRawPointer?.self, capacity: 1)
    link = nil
    (storage+dataOffset).bindMemory(to: AtomicOptionalMutableRawPointer.self, capacity: 1)
    data = AtomicOptionalMutableRawPointer(pointer)
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

  var link: UnsafeMutableRawPointer? {
    @inlinable unsafeAddress {
      return UnsafeRawPointer(storage+linkOffset).assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+linkOffset).assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
    }
  }

  var prev: TaggedMutableRawPointer {
    @inlinable unsafeAddress {
      return UnsafeRawPointer(storage+prevOffset).assumingMemoryBound(to: TaggedMutableRawPointer.self)
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+prevOffset).assumingMemoryBound(to: TaggedMutableRawPointer.self)
    }
  }

  var next: AtomicTaggedOptionalMutableRawPointer {
    @inlinable unsafeAddress {
      return UnsafeRawPointer(storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
    }
  }

  var data: AtomicOptionalMutableRawPointer {
    @inlinable unsafeAddress {
      return UnsafeRawPointer(storage+dataOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+dataOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  func initialize(to element: UnsafeMutableRawPointer)
  {
    next.store(nullNode, .relaxed)
    data.store(element, .release)
  }
}
