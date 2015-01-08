//
//  atomicqueue.h
//  QQ
//
//  Created by Guillaume Lessard on 2014-12-30.
//  Copyright (c) 2014 Guillaume Lessard. All rights reserved.
//

#ifndef QQ_atomicqueue_h
#define QQ_atomicqueue_h

#import <libkern/OSAtomic.h>

OSFifoQueueHead* AtomicQueueInit();

void AtomicQueueRelease(OSFifoQueueHead* h);

long AtomicQueueCountNodes(OSFifoQueueHead* h, size_t offset);


OSQueueHead* AtomicStackInit();

void AtomicStackRelease(OSQueueHead* h);

long AtomicStackCountNodes(OSQueueHead* h, size_t offset);

#endif
