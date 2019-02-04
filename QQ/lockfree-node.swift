//
//  lockfree-node.swift
//  QQ
//
//  Created by Guillaume Lessard on 06/09/2016.
//  Copyright © 2016 Guillaume Lessard. All rights reserved.
//

import CAtomics

private let nextOffset = MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride
private let prevOffset = nextOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride
private let dataOffset = prevOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride

struct LockFreeNode<Element>: OSAtomicNode, Equatable
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

  init()
  {
    let size = dataOffset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 16)
    storage.bindMemory(to: (UnsafeMutableRawPointer?).self, capacity: 1).initialize(repeating: nil, count: 1)
    (storage+nextOffset).bindMemory(to: AtomicTaggedOptionalMutableRawPointer.self, capacity: 2)
    (storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self).pointee = AtomicTaggedOptionalMutableRawPointer()
    (storage+prevOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self).pointee = AtomicTaggedOptionalMutableRawPointer()
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1)
  }

  init(initializedWith element: Element)
  {
    self.init()
    (storage+dataOffset).assumingMemoryBound(to: Element.self).initialize(to: element)
  }

  func deallocate()
  {
    storage.deallocate()
  }

  var prev: UnsafeMutablePointer<AtomicTaggedOptionalMutableRawPointer> {
    get {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
    }
  }

  var next: UnsafeMutablePointer<AtomicTaggedOptionalMutableRawPointer> {
    get {
      return (storage+prevOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
    }
  }

  func initialize(to element: Element)
  {
    storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = nil
    let tmrp = TaggedOptionalMutableRawPointer(nil, tag: 0)
    (storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self).pointee.initialize(tmrp)
    (storage+prevOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self).pointee.initialize(tmrp)
    (storage+dataOffset).assumingMemoryBound(to: Element.self).initialize(to: element)
  }

  func deinitialize()
  {
    (storage+dataOffset).assumingMemoryBound(to: Element.self).deinitialize(count: 1)
  }

  func read() -> Element?
  {
    return (storage+dataOffset).assumingMemoryBound(to: Element.self).pointee
  }
}
