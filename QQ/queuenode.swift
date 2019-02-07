//
//  queuenode.swift
//  QQ
//
//  Created by Guillaume Lessard on 4/19/17.
//  Copyright © 2017 Guillaume Lessard. All rights reserved.
//

import struct CAtomics.AtomicOptionalMutableRawPointer

private let linkOffset = 0
private let nextOffset = linkOffset + MemoryLayout<AtomicOptionalMutableRawPointer>.stride

struct QueueNode<Element>: OSAtomicNode, StackNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  private var dataOffset: Int {
    let a = MemoryLayout<Element>.alignment
    let d = (nextOffset + MemoryLayout<UnsafeMutableRawPointer?>.stride - a)/a
    return a*d+a
  }

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  private init?(storage: UnsafeMutableRawPointer?)
  {
    guard let storage = storage else { return nil }
    self.storage = storage
  }

  private init()
  {
    let a = MemoryLayout<Element>.alignment
    let d = (nextOffset + MemoryLayout<UnsafeMutableRawPointer?>.stride - a)/a
    let size = a*d+a + MemoryLayout<Element>.stride
    let alignment = max(MemoryLayout<Element>.alignment, MemoryLayout<UnsafeMutableRawPointer?>.alignment)
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+linkOffset).bindMemory(to: AtomicOptionalMutableRawPointer.self, capacity: 1)
    link = AtomicOptionalMutableRawPointer(nil)
    (storage+nextOffset).bindMemory(to: (UnsafeMutableRawPointer?).self, capacity: 1)
    next = nil
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1)
  }

  static var dummy: QueueNode { return QueueNode() }

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
    @inlinable unsafeAddress {
      return UnsafePointer((storage+linkOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self))
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+linkOffset).assumingMemoryBound(to: AtomicOptionalMutableRawPointer.self)
    }
  }

  private var nptr: UnsafeMutablePointer<UnsafeMutableRawPointer?> {
    return (storage+nextOffset).assumingMemoryBound(to: (UnsafeMutableRawPointer?).self)
  }

  var next: QueueNode? {
    @inlinable get {
      return QueueNode(storage: nptr.pointee)
    }
    @inlinable nonmutating set {
      nptr.pointee = newValue?.storage
    }
  }

  private var data: UnsafeMutablePointer<Element> {
    return (storage+dataOffset).assumingMemoryBound(to: Element.self)
  }

  func initialize(to element: Element)
  {
    next = nil
    data.initialize(to: element)
  }

  func deinitialize()
  {
    data.deinitialize(count: 1)
  }

  @discardableResult
  func move() -> Element
  {
    return data.move()
  }
}
