//
//  lockfree-node.swift
//  QQ
//
//  Created by Guillaume Lessard on 06/09/2016.
//  Copyright © 2016 Guillaume Lessard. All rights reserved.
//

import CAtomics

private let linkOffset = 0
private let prevOffset = linkOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.alignment
private let nextOffset = prevOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride

struct LockFreeNode<Element>: OSAtomicNode, StackNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  private var dataOffset: Int {
    let a = MemoryLayout<Element>.alignment
    let d = (nextOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride - a)/a
    return a*d+a
  }

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  init?(storage: UnsafeMutableRawPointer?)
  {
    guard let storage = storage else { return nil }
    self.storage = storage
  }

  private init()
  {
    let alignment = max(MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.alignment, MemoryLayout<Element>.alignment)
    let a = MemoryLayout<Element>.alignment
    let d = (nextOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride - a)/a
    let size = a*d+a + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+linkOffset).bindMemory(to: AtomicOptionalMutableRawPointer.self, capacity: 1)
    link.pointee = AtomicOptionalMutableRawPointer(nil)
    (storage+nextOffset).bindMemory(to: AtomicTaggedOptionalMutableRawPointer.self, capacity: 2)
    let tmrp = TaggedOptionalMutableRawPointer(nil, tag: 0)
    next.pointee = AtomicTaggedOptionalMutableRawPointer(tmrp)
    prev.pointee = AtomicTaggedOptionalMutableRawPointer(tmrp)
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1)
  }

  static var dummy: LockFreeNode { return LockFreeNode() }

  init(initializedWith element: Element)
  {
    self.init()
    let data = (storage+dataOffset).assumingMemoryBound(to: Element.self)
    data.initialize(to: element)
  }

  func deallocate()
  {
    storage.deallocate()
  }

  var link: UnsafeMutablePointer<AtomicOptionalMutableRawPointer> {
    get {
      return (storage+linkOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  var prev: UnsafeMutablePointer<AtomicTaggedOptionalMutableRawPointer> {
    get {
      return (storage+prevOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
    }
  }

  var next: UnsafeMutablePointer<AtomicTaggedOptionalMutableRawPointer> {
    get {
      return (storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
    }
  }

  func initialize(to element: Element)
  {
    storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = nil
    link.pointee.store(nil, .relaxed)
    let tmrp = TaggedOptionalMutableRawPointer(nil, tag: 0)
    next.pointee.store(tmrp, .relaxed)
    prev.pointee.store(tmrp, .relaxed)
    let data = (storage+dataOffset).assumingMemoryBound(to: Element.self)
    data.initialize(to: element)
  }

  func deinitialize()
  {
    let data = (storage+dataOffset).assumingMemoryBound(to: Element.self)
    data.deinitialize(count: 1)
  }

  func read() -> Element?
  {
    return (storage+dataOffset).assumingMemoryBound(to: Element.self).pointee
  }
}
