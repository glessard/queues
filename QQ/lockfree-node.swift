//
//  lockfree-node.swift
//  QQ
//
//  Created by Guillaume Lessard on 06/09/2016.
//  Copyright © 2016 Guillaume Lessard. All rights reserved.
//

private let linkOffset1 = MemoryLayout<UnsafeMutableRawPointer>.stride
private let linkOffset2 = MemoryLayout<UnsafeMutableRawPointer>.stride + MemoryLayout<TaggedPointer<LockFreeNode<Int>>>.stride
private let dataOffset =  MemoryLayout<UnsafeMutableRawPointer>.stride + 2*MemoryLayout<TaggedPointer<LockFreeNode<Int>>>.stride

struct LockFreeNode<Element>: OSAtomicNode
{
  let storage: UnsafeMutableRawPointer

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  init()
  {
    let size = dataOffset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(bytes: size, alignedTo: 16)
    storage.bindMemory(to: (UnsafeMutableRawPointer?).self, capacity: 1).initialize(to: nil, count: 1)
    (storage+linkOffset1).bindMemory(to: TaggedPointer<LockFreeNode<Element>>.self, capacity: 2)
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1)
  }

  init(initializedWith element: Element)
  {
    let size = dataOffset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(bytes: size, alignedTo: 16)
    storage.bindMemory(to: (UnsafeMutableRawPointer?).self, capacity: 1).initialize(to: nil, count: 1)
    (storage+linkOffset1).bindMemory(to: TaggedPointer<LockFreeNode<Element>>.self, capacity: 2)
    (storage+dataOffset).bindMemory(to: Element.self, capacity: 1).initialize(to: element)
  }

  func deallocate()
  {
    let size = dataOffset + MemoryLayout<Element>.stride
    storage.deallocate(bytes: size, alignedTo: 16)
  }

  var pointer: UnsafeMutablePointer<LockFreeNode<Element>> {
    get {
      return storage.assumingMemoryBound(to: LockFreeNode<Element>.self)
    }
  }

  var prev: UnsafeMutablePointer<TaggedPointer<LockFreeNode<Element>>> {
    get {
      return (storage+linkOffset1).assumingMemoryBound(to: (TaggedPointer<LockFreeNode<Element>>).self)
    }
  }

  var next: UnsafeMutablePointer<TaggedPointer<LockFreeNode<Element>>> {
    get {
      return (storage+linkOffset2).assumingMemoryBound(to: (TaggedPointer<LockFreeNode<Element>>).self)
    }
  }

  func initialize(to element: Element)
  {
    storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = nil
    (storage+dataOffset).assumingMemoryBound(to: Element.self).initialize(to: element)
  }

  func deinitialize()
  {
    (storage+dataOffset).assumingMemoryBound(to: Element.self).deinitialize()
  }

  @discardableResult
  func read() -> Element
  {
    return (storage+dataOffset).assumingMemoryBound(to: Element.self).pointee
  }
}
