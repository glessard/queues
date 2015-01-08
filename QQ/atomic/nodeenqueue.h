//
//  nodeenqueue.h
//  QQ
//
//  Created by Guillaume Lessard on 2015-01-08.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

#ifndef QQ_nodeenqueue_h
#define QQ_nodeenqueue_h

void RefNodeEnqueue(OSFifoQueueHead* h, id item);

id   RefNodeDequeue(OSFifoQueueHead* h);

long RefNodeCountNodes(OSFifoQueueHead* h);


void RefNodeEnqueue2(OSFifoQueueHead* head, OSFifoQueueHead* pool, id item);

id   RefNodeDequeue2(OSFifoQueueHead* head, OSFifoQueueHead* pool);


void  PointerNodeEnqueue(OSFifoQueueHead* h, void* item);

void* PointerNodeDequeue(OSFifoQueueHead* h);

long  PointerNodeCountNodes(OSFifoQueueHead* h);

#endif
