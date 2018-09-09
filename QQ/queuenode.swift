//
//  queuenode.swift
//  QQ
//
//  Created by Guillaume Lessard on 4/19/17.
//  Copyright © 2017 Guillaume Lessard. All rights reserved.
//

private let offset = MemoryLayout<UnsafeMutableRawPointer>.stride

struct QueueNode<Element>: OSAtomicNode
{
  let storage: UnsafeMutableRawPointer

  init(storage: UnsafeMutableRawPointer)
  {
    self.storage = storage
  }

  init()
  {
    let size = offset + MemoryLayout<Element>.stride
    storage = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 16)
    storage.bindMemory(to: (UnsafeMutableRawPointer?).self, capacity: 1).pointee = nil
    (storage+offset).bindMemory(to: Element.self, capacity: 1)
  }

  init(initializedWith element: Element)
  {
    self.init()
    (storage+offset).assumingMemoryBound(to: Element.self).initialize(to: element)
  }

  func deallocate()
  {
    storage.deallocate()
  }

  var next: QueueNode? {
    get {
      if let s = storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee
      {
        return QueueNode(storage: s)
      }
      return nil
    }
    nonmutating set {
      storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = newValue?.storage
    }
  }

  func initialize(to element: Element)
  {
    storage.assumingMemoryBound(to: (UnsafeMutableRawPointer?).self).pointee = nil
    (storage+offset).assumingMemoryBound(to: Element.self).initialize(to: element)
  }

  func deinitialize()
  {
    (storage+offset).assumingMemoryBound(to: Element.self).deinitialize(count: 1)
  }

  @discardableResult
  func move() -> Element
  {
    return (storage+offset).assumingMemoryBound(to: Element.self).move()
  }
}
