//
//  nodeenqueue.m
//  QQ
//
//  Created by Guillaume Lessard on 2015-01-08.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "linknodes.h"
#import "nodeenqueue.h"

void RefNodeEnqueue(OSFifoQueueHead* h, id item)
{
  struct RefNode* node = calloc(1, sizeof(struct RefNode));
  node->elem = CFBridgingRetain(item);
  OSAtomicFifoEnqueue(h, node, offsetof(struct RefNode, next));
}

id RefNodeDequeue(OSFifoQueueHead* h)
{
  id item = NULL;
  struct RefNode* node = OSAtomicFifoDequeue(h, offsetof(struct RefNode, next));

  if (node != NULL)
  {
    if (node->elem != NULL)
    {
      item = CFBridgingRelease(node->elem);
    }
    free(node);
  }

  return item;
}

long RefNodeCountNodes(OSFifoQueueHead* h)
{
  return AtomicQueueCountNodes(h, offsetof(struct RefNode, next));
}


void RefNodeEnqueue2(OSFifoQueueHead* head, OSFifoQueueHead* pool, id item)
{
  struct RefNode* node = OSAtomicFifoDequeue(pool, offsetof(struct RefNode, next));
  if (node == NULL)
  {
    node = calloc(1, sizeof(struct RefNode));
  }

  // assert (node != NULL)
  // assert (node->elem == NULL)

  node->elem = CFBridgingRetain(item);
  OSAtomicFifoEnqueue(head, node, offsetof(struct RefNode, next));
}

id RefNodeDequeue2(OSFifoQueueHead* head, OSFifoQueueHead* pool)
{
  id item = NULL;
  struct RefNode* node = OSAtomicFifoDequeue(head, offsetof(struct RefNode, next));

  if (node != NULL)
  {
    if (node->elem != NULL)
    {
      item = CFBridgingRelease(node->elem);
      node->elem = NULL;
    }
    OSAtomicFifoEnqueue(pool, node, offsetof(struct RefNode, next));
  }

  return item;
}


void PointerNodeEnqueue(OSFifoQueueHead* h, void* item)
{
  struct PointerNode* node = calloc(1, sizeof(struct PointerNode));
  node->elem = item;
  OSAtomicFifoEnqueue(h, node, offsetof(struct PointerNode, next));
}

void* PointerNodeDequeue(OSFifoQueueHead* h)
{
  void* item = NULL;
  struct PointerNode* node = OSAtomicFifoDequeue(h, offsetof(struct PointerNode, next));

  if (node != NULL)
  {
    if (node->elem != NULL)
    {
      item = node->elem;
    }
    free(node);
  }

  return item;
}

long PointerNodeCountNodes(OSFifoQueueHead* h)
{
  return AtomicQueueCountNodes(h, offsetof(struct PointerNode, next));
}
