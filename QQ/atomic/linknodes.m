//
//  linknodes.m
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-27.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <stdlib.h>

#import "linknodes.h"


size_t PointerNodeLinkOffset()
{
  return offsetof(struct PointerNode, next);
}

size_t PointerNodeSize()
{
  return sizeof(struct PointerNode);
}


size_t RefNodeLinkOffset()
{
  return offsetof(struct RefNode, next);
}

size_t RefNodeSize()
{
  return sizeof(struct RefNode);
}


struct RefNode* RefNodeInsert(id item)
{
  struct RefNode* node = calloc(1, sizeof(struct RefNode));
  node->elem = CFBridgingRetain(item);
  return node;
}

id RefNodeExtract(struct RefNode* node)
{
  id item = NULL;

  if (node != NULL)
  {
    item = CFBridgingRelease(node->elem);
    free(node);
  }

  return item;
}

struct RefNode* RefNodeInsertCF(CFTypeRef item)
{
  struct RefNode* node = calloc(1, sizeof(struct RefNode));
  node->elem = CFRetain(item);
  return node;
}

CFTypeRef RefNodeExtractCF(struct RefNode* node)
{
  CFTypeRef item = NULL;

  if (node != NULL)
  {
    // CFGetRetainCount(node->elem);
    item = node->elem;
    free(node);
    // CFGetRetainCount(item);
  }

  return item;
}

void pointerPrint(void* p)
{
  printf("%llx\n", (unsigned long long)p);
}
