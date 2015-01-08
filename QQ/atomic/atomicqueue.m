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

