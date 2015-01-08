//
//  linknodes.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-01-06.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

struct LinkNode
{
  var next: UnsafeMutablePointer<LinkNode> = nil
  var elem: COpaquePointer = nil
}

struct RefLinkNode
{
  var next: UnsafeMutablePointer<RefLinkNode> = nil
  var elem: Unmanaged<AnyObject>
}


struct LinkNodeQueueData
{
  var head: UnsafeMutablePointer<LinkNode> = nil
  var tail: UnsafeMutablePointer<LinkNode> = nil

  var lock: Int32 = OS_SPINLOCK_INIT
}

