//
//  lockfree-node.swift
//  QQ
//
//  Created by Guillaume Lessard on 06/09/2016.
//  Copyright © 2016 Guillaume Lessard. All rights reserved.
//

private let offset = MemoryLayout<UnsafeMutableRawPointer>.stride

struct LockFreeNode<Element>: OSAtomicNode
{
  let storage: UnsafeMutableRawPointer

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  init()
  {
    let size = offset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(bytes: size, alignedTo: 16)
    storage.bindMemory(to: (UnsafeMutableRawPointer?).self, capacity: 3).initialize(to: nil, count: 3)
    (storage+offset).bindMemory(to: Element.self, capacity: 1)
  }

  init(initializedWith element: Element)
  {
    let size = offset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(bytes: size, alignedTo: 16)
    storage.bindMemory(to: (UnsafeMutableRawPointer?).self, capacity: 3).initialize(to: nil, count: 3)
    (storage+offset).bindMemory(to: Element.self, capacity: 1).initialize(to: element)
  }

  func deallocate()
  {
    let size = offset + MemoryLayout<Element>.stride
    storage.deallocate(bytes: size, alignedTo: MemoryLayout<UnsafeMutableRawPointer>.alignment)
  }

  var pointer: UnsafeMutablePointer<LockFreeNode<Element>> {
    get {
      return storage.assumingMemoryBound(to: LockFreeNode<Element>.self)
    }
  }

  var prev: TaggedPointer<LockFreeNode<Element>> {
    get {
      return (storage+2*offset).assumingMemoryBound(to: (TaggedPointer<LockFreeNode<Element>>).self).pointee
    }
    nonmutating set {
      (storage+2*offset).assumingMemoryBound(to: (TaggedPointer<LockFreeNode<Element>>).self).pointee = newValue
    }
  }

  var next: TaggedPointer<LockFreeNode<Element>> {
    get {
      return (storage+3*offset).assumingMemoryBound(to: (TaggedPointer<LockFreeNode<Element>>).self).pointee
    }
    nonmutating set {
      (storage+3*offset).assumingMemoryBound(to: (TaggedPointer<LockFreeNode<Element>>).self).pointee = newValue
    }
  }

  func initialize(to element: Element)
  {
    storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = nil
    (storage+offset).assumingMemoryBound(to: Element.self).initialize(to: element)
  }

  func deinitialize()
  {
    (storage+offset).assumingMemoryBound(to: Element.self).deinitialize()
  }

  @discardableResult
  func move() -> Element
  {
    return (storage+offset).assumingMemoryBound(to: Element.self).move()
  }
}
