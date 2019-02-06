//
//  lockfree-node.swift
//  QQ
//
//  Created by Guillaume Lessard on 06/09/2016.
//  Copyright © 2016 Guillaume Lessard. All rights reserved.
//

import CAtomics

private let linkOffset = 0
private let prevOffset = linkOffset + max(MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.alignment,
                                          MemoryLayout<AtomicOptionalMutableRawPointer>.stride)
private let nextOffset = prevOffset + MemoryLayout<AtomicTaggedOptionalMutableRawPointer>.stride

private let nullNode = TaggedOptionalMutableRawPointer(nil, tag: 0)

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
    link = AtomicOptionalMutableRawPointer(nil)
    (storage+nextOffset).bindMemory(to: AtomicTaggedOptionalMutableRawPointer.self, capacity: 2)
    next.pointee = AtomicTaggedOptionalMutableRawPointer(nullNode)
    prev.pointee = AtomicTaggedOptionalMutableRawPointer(nullNode)
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1)
  }

  static var dummy: LockFreeNode { return LockFreeNode() }

  init(initializedWith element: Element)
  {
    self.init()
    data.initialize(to: element)
  }

  func deallocate()
  {
    storage.deallocate()
  }

  var link: AtomicOptionalMutableRawPointer {
    unsafeAddress {
      return UnsafePointer((storage+linkOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self))
    }
    nonmutating unsafeMutableAddress {
      return (storage+linkOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  var prev: UnsafeMutablePointer<AtomicTaggedOptionalMutableRawPointer> {
    return (storage+prevOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
  }

  var next: UnsafeMutablePointer<AtomicTaggedOptionalMutableRawPointer> {
    return (storage+nextOffset).assumingMemoryBound(to: AtomicTaggedOptionalMutableRawPointer.self)
  }

  var data: UnsafeMutablePointer<Element> {
    return (storage+dataOffset).assumingMemoryBound(to: Element.self)
  }

  func initialize(to element: Element)
  {
    next.pointee.store(nullNode, .relaxed)
    prev.pointee.store(nullNode, .relaxed)
    data.initialize(to: element)
  }

  func deinitialize()
  {
    data.deinitialize(count: 1)
  }

  func read() -> Element?
  {
    return data.pointee
  }
}
