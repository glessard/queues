//
//  lockfree-stack.swift
//  QQ
//
//  Copyright © 2016-2019 Guillaume Lessard. All rights reserved.
//

import CAtomics

protocol StackNode: OSAtomicNode
{
  func deallocate()
  var link: UnsafeMutablePointer<AtomicOptionalMutableRawPointer> { get }
}

/// AtomicStack implements a free-element list using Treiber's algorithm
/// R. K. Treiber. Systems Programming: Coping with Parallelism.
/// In RJ 5118, IBM Almaden Research Center, April 1986.
/// See also https://en.wikipedia.org/wiki/Treiber_stack
///
/// A push() or pop() operation should fail to make progress only when
/// another operation has succeeded on another thread.

class AtomicStack<T: StackNode>
{
  private var head = AtomicTaggedOptionalMutableRawPointer()

  init()
  {
    head.initialize(TaggedOptionalMutableRawPointer(nil, tag: 0))
  }

  deinit {
    while let node = self.pop() { node.deallocate() }
  }

  func push(_ node: T)
  {
    var oldHead = self.head.load(.relaxed)
    var newHead: TaggedOptionalMutableRawPointer
    repeat {
      node.link.pointee.store(oldHead.ptr, .relaxed)
      newHead = TaggedOptionalMutableRawPointer(node.storage, tag: oldHead.tag &+ 1)
    } while !self.head.loadCAS(&oldHead, newHead, .weak, .release, .relaxed)
  }

  func pop() -> T?
  {
    var oldHead = self.head.load(.acquire)
    var newHead: TaggedOptionalMutableRawPointer
    var node: T
    repeat {
      guard let storage = oldHead.ptr else { return nil }
      node = T(storage: storage)
      let linked = node.link.pointee.load(.relaxed)
      newHead = TaggedOptionalMutableRawPointer(linked, tag: oldHead.tag &+ 1)
    } while !self.head.loadCAS(&oldHead, newHead, .weak, .acquire, .acquire)
    node.link.pointee.store(nil, .relaxed)
    return node
  }
}
