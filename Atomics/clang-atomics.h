//
//  clang-atomics.h
//  Test23
//
//  Created by Guillaume Lessard on 2015-05-21.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

#ifndef Test23_clang_atomics_h
#define Test23_clang_atomics_h

// Pointer

const void* LoadVoidPtr(void** var);
const void* SyncLoadVoidPtr(void** var);
void StoreVoidPtr(const void* val, void** var);
void SyncStoreVoidPtr(const void* val, void** var);
const void* SwapVoidPtr(const void* val, void** var);

// 32-bit integer

int Load32(int* var);
int SyncLoad32(int* var);
void Store32(int val, int* var);
void SyncStore32(int val, int* var);
int Swap32(int val, int* var);
int Add32(int increment, int* ptr);
int Sub32(int increment, int* ptr);
int Increment32(int* ptr);
int Decrement32(int* ptr);

// pointer-sized integer

long LoadLong(long *var);
long SyncLoadLong(long *var);
void StoreLong(long val, long *var);
void SyncStoreLong(long val, long *var);
long SwapLong(long val, long* var);
long AddLong(long increment, long* ptr);
long SubLong(long increment, long* ptr);
long IncrementLong(long* ptr);
long DecrementLong(long* ptr);

// 64-bit integer

long long Load64(long long *var);
long long SyncLoad64(long long *var);
void Store64(long long val, long long *var);
void SyncStore64(long long val, long long *var);
long long Swap64(long long val, long long *var);
long long Add64(long long increment, long long* ptr);
long long Sub64(long long increment, long long* ptr);
long long Increment64(long long* ptr);
long long Decrement64(long long* ptr);

#endif
