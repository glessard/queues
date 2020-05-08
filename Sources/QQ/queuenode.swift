//
//  queuenode.swift
//  QQ
//
//  Created by Guillaume Lessard on 4/19/17.
//  Copyright © 2017 Guillaume Lessard. All rights reserved.
//

private struct NodePrefix
{
  var link: UnsafeMutableRawPointer?
  var next: UnsafeMutableRawPointer?
}

private let linkOffset = MemoryLayout.offset(of: \NodePrefix.link)!
private let nextOffset = MemoryLayout.offset(of: \NodePrefix.next)!

struct QueueNode<Element>: OSAtomicNode, StackNode, Equatable
{
  let storage: UnsafeMutableRawPointer

  private var dataOffset: Int {
    let dataMask = MemoryLayout<Element>.alignment - 1
    return (MemoryLayout<NodePrefix>.size + dataMask) & ~dataMask
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
    let alignment  = max(MemoryLayout<NodePrefix>.alignment, MemoryLayout<Element>.alignment)
    let dataMask   = MemoryLayout<Element>.alignment - 1
    let dataOffset = (MemoryLayout<NodePrefix>.size + dataMask) & ~dataMask
    let size = dataOffset + MemoryLayout<Element>.size
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    (storage+linkOffset).bindMemory(to: UnsafeMutableRawPointer?.self, capacity: 2)
    link = nil
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

  var link: UnsafeMutableRawPointer? {
    @inlinable unsafeAddress {
      return UnsafeRawPointer(storage+linkOffset).assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
    }
    @inlinable nonmutating unsafeMutableAddress {
      return (storage+linkOffset).assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
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
