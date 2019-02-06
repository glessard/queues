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
  var link: AtomicOptionalMutableRawPointer { get nonmutating set }
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
  private var head: AtomicTaggedOptionalMutableRawPointer

  init()
  {
    let node01 = TaggedOptionalMutableRawPointer(nil, tag: 1)
    head = AtomicTaggedOptionalMutableRawPointer(node01)
  }

  deinit {
    while let node = self.pop() { node.deallocate() }
  }

  func push(_ node: T)
  {
    var oldHead = self.head.load(.relaxed)
    var newHead: TaggedOptionalMutableRawPointer
    repeat {
      node.link.store(oldHead.ptr, .relaxed)
      newHead = oldHead.incremented(with: node.storage)
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
      newHead = oldHead.incremented(with: node.link.load(.relaxed))
    } while !self.head.loadCAS(&oldHead, newHead, .weak, .acquire, .acquire)
    return node
  }
}
