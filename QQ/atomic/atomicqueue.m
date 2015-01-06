//
//  atomicqueue.m
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stddef.h>

#import "atomicqueue.h"
#import "linknodes.h"

OSFifoQueueHead* AtomicQueueInit()
{
  return (OSFifoQueueHead*) calloc(1, sizeof(OSFifoQueueHead));
}

void AtomicQueueRelease(OSFifoQueueHead* h)
{
  free((void*)h);
}

long AtomicQueueCountNodes(OSFifoQueueHead* h, size_t offset)
{
  long count = 0;
  void* node = h->opaque1;
  if (node != NULL)
  {
    count++;

    void** x = (node+offset);
    while (*x != NULL)
    {
      count++;
      x = (*x+offset);
    }
  }
//  printf("%ld %d", count, h->opaque3);

  return count;
}


OSQueueHead* AtomicStackInit()
{
  return (OSQueueHead*) calloc(1, sizeof(OSQueueHead));
}

void AtomicStackRelease(OSQueueHead* h)
{
  free((void*)h);
}

long AtomicStackCountNodes(OSQueueHead* h, size_t offset)
{
  long count = 0;
  void* node = h->opaque1;
  if (node != NULL)
  {
    count++;

    void** x = (node+offset);
    while (*x != NULL)
    {
      count++;
      x = (*x+offset);
    }
  }
//  printf("%ld %ld", count, h->opaque2);

  return count;
}


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
