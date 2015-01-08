//
//  linknodes.h
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-27.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

#ifndef QQ_linknodes_h
#define QQ_linknodes_h

#import <CoreFoundation/CFBase.h>

struct PointerNode
{
  struct PointerNode* next;
  void*               elem;
};

size_t PointerNodeLinkOffset();
size_t PointerNodeSize();


struct RefNode
{
  struct RefNode* next;
  CFTypeRef       elem;
};

size_t RefNodeLinkOffset();
size_t RefNodeSize();

struct RefNode* RefNodeInsert(id item);
id RefNodeExtract(struct RefNode* node);

struct RefNode* RefNodeInsertCF(CFTypeRef item);
CFTypeRef RefNodeExtractCF(struct RefNode* node);

#endif
