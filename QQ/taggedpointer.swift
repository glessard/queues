//
//  TaggedPointer.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-09-09.
//  Copyright © 2015 Guillaume Lessard. All rights reserved.
//

import CAtomics

extension TaggedMutableRawPointer: Equatable
{
  public static func ==(lhs: TaggedMutableRawPointer, rhs: TaggedMutableRawPointer) -> Bool
  {
    return (lhs.ptr == rhs.ptr) && (lhs.tag == rhs.tag)
  }
}
