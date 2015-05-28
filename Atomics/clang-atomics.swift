//
//  clang-atomics.swift
//  Test23
//
//  Created by Guillaume Lessard on 2015-05-21.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

// MARK: Pointer Atomics

@inline(__always) func Load<T>(p: UnsafeMutablePointer<UnsafePointer<T>>) -> UnsafePointer<T>
{
  return UnsafePointer<T>(LoadVoidPtr(UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p)))
}

@inline(__always) func Load<T>(p: UnsafeMutablePointer<UnsafeMutablePointer<T>>) -> UnsafeMutablePointer<T>
{
  return UnsafeMutablePointer<T>(LoadVoidPtr(UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p)))
}


@inline(__always) func SyncLoad<T>(p: UnsafeMutablePointer<UnsafePointer<T>>) -> UnsafePointer<T>
{
  return UnsafePointer<T>(SyncLoadVoidPtr(UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p)))
}

@inline(__always) func SyncLoad<T>(p: UnsafeMutablePointer<UnsafeMutablePointer<T>>) -> UnsafeMutablePointer<T>
{
  return UnsafeMutablePointer<T>(SyncLoadVoidPtr(UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p)))
}


@inline(__always) func Store<T>(v: UnsafePointer<T>, p: UnsafeMutablePointer<UnsafePointer<T>>)
{
  StoreVoidPtr(v, UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p))
}

@inline(__always) func Store<T>(v: UnsafeMutablePointer<T>, p: UnsafeMutablePointer<UnsafeMutablePointer<T>>)
{
  StoreVoidPtr(v, UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p))
}


@inline(__always) func SyncStore<T>(v: UnsafePointer<T>, p: UnsafeMutablePointer<UnsafePointer<T>>)
{
  SyncStoreVoidPtr(v, UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p))
}

@inline(__always) func SyncStore<T>(v: UnsafeMutablePointer<T>, p: UnsafeMutablePointer<UnsafeMutablePointer<T>>)
{
  SyncStoreVoidPtr(v, UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p))
}


@inline(__always) func Swap<T>(v: UnsafePointer<T>, p: UnsafeMutablePointer<UnsafePointer<T>>) -> UnsafePointer<T>
{
  return UnsafePointer<T>(SwapVoidPtr(v, UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p)))
}

@inline(__always) func Swap<T>(v: UnsafePointer<T>, p: UnsafeMutablePointer<UnsafeMutablePointer<T>>) -> UnsafeMutablePointer<T>
{
  return UnsafeMutablePointer<T>(SwapVoidPtr(v, UnsafeMutablePointer<UnsafeMutablePointer<Void>>(p)))
}


// MARK: Int and UInt Atomics

@inline(__always) func Load(p: UnsafeMutablePointer<Int>) -> Int
{
  return LoadLong(p)
}

@inline(__always) func Load(p: UnsafeMutablePointer<UInt>) -> UInt
{
  return UInt(bitPattern: LoadLong(UnsafeMutablePointer(p)))
}

@inline(__always) func SyncLoad(p: UnsafeMutablePointer<Int>) -> Int
{
  return SyncLoadLong(p)
}

@inline(__always) func SyncLoad(p: UnsafeMutablePointer<UInt>) -> UInt
{
  return UInt(bitPattern: SyncLoadLong(UnsafeMutablePointer(p)))
}

@inline(__always) func Store(v: Int, p: UnsafeMutablePointer<Int>)
{
  StoreLong(v, p)
}

@inline(__always) func Store(v: UInt, p: UnsafeMutablePointer<UInt>)
{
  StoreLong(unsafeBitCast(v, Int.self), UnsafeMutablePointer(p))
}

@inline(__always) func SyncStore(v: Int, p: UnsafeMutablePointer<Int>)
{
  SyncStoreLong(v, p)
}

@inline(__always) func SyncStore(v: UInt, p: UnsafeMutablePointer<UInt>)
{
  SyncStoreLong(unsafeBitCast(v, Int.self), UnsafeMutablePointer(p))
}

@inline(__always) func Swap(v: Int, p: UnsafeMutablePointer<Int>) -> Int
{
  return SwapLong(v, p)
}

@inline(__always) func Swap(v: UInt, p: UnsafeMutablePointer<UInt>) -> UInt
{
  return UInt(bitPattern: SwapLong(unsafeBitCast(v, Int.self), UnsafeMutablePointer(p)))
}

@inline(__always) func Add(i: Int, p: UnsafeMutablePointer<Int>) -> Int
{
  return AddLong(i, p)
}

@inline(__always) func Add(i: UInt, p: UnsafeMutablePointer<UInt>) -> UInt
{
  return UInt(bitPattern: AddLong(unsafeBitCast(i, Int.self), UnsafeMutablePointer(p)))
}

@inline(__always) func Sub(i: Int, p: UnsafeMutablePointer<Int>) -> Int
{
  return SubLong(i, p)
}

@inline(__always) func Sub(i: UInt, p: UnsafeMutablePointer<UInt>) -> UInt
{
  return UInt(bitPattern: SubLong(unsafeBitCast(i, Int.self), UnsafeMutablePointer(p)))
}

@inline(__always) func Increment(p: UnsafeMutablePointer<Int>) -> Int
{
  return IncrementLong(p)
}

@inline(__always) func Increment(p: UnsafeMutablePointer<UInt>) -> UInt
{
  return UInt(bitPattern: IncrementLong(UnsafeMutablePointer(p)))
}

@inline(__always) func Decrement(p: UnsafeMutablePointer<Int>) -> Int
{
  return DecrementLong(p)
}

@inline(__always) func Decrement(p: UnsafeMutablePointer<UInt>) -> UInt
{
  return UInt(bitPattern: DecrementLong(UnsafeMutablePointer(p)))
}

// MARK: Int32 and UInt32 Atomics

@inline(__always) func Load(p: UnsafeMutablePointer<Int32>) -> Int32
{
  return Load32(p)
}

@inline(__always) func Load(p: UnsafeMutablePointer<UInt32>) -> UInt32
{
  return UInt32(bitPattern: Load32(UnsafeMutablePointer(p)))
}

@inline(__always) func SyncLoad(p: UnsafeMutablePointer<Int32>) -> Int32
{
  return SyncLoad32(p)
}

@inline(__always) func SyncLoad(p: UnsafeMutablePointer<UInt32>) -> UInt32
{
  return UInt32(bitPattern: SyncLoad32(UnsafeMutablePointer(p)))
}

@inline(__always) func Store(v: Int32, p: UnsafeMutablePointer<Int32>)
{
  Store32(v, p)
}

@inline(__always) func Store(v: UInt32, p: UnsafeMutablePointer<UInt32>)
{
  Store32(unsafeBitCast(v, Int32.self), UnsafeMutablePointer(p))
}

@inline(__always) func SyncStore(v: Int32, p: UnsafeMutablePointer<Int32>)
{
  SyncStore32(v, p)
}

@inline(__always) func SyncStore(v: UInt32, p: UnsafeMutablePointer<UInt32>)
{
  SyncStore32(unsafeBitCast(v, Int32.self), UnsafeMutablePointer(p))
}

@inline(__always) func Swap(v: Int32, p: UnsafeMutablePointer<Int32>) -> Int32
{
  return Swap32(v, p)
}

@inline(__always) func Swap(v: UInt32, p: UnsafeMutablePointer<UInt32>) -> UInt32
{
  return UInt32(bitPattern: Swap32(unsafeBitCast(v, Int32.self), UnsafeMutablePointer(p)))
}

@inline(__always) func Add(i: Int32, p: UnsafeMutablePointer<Int32>) -> Int32
{
  return Add32(i, p)
}

@inline(__always) func Add(i: UInt32, p: UnsafeMutablePointer<UInt32>) -> UInt32
{
  return UInt32(bitPattern: Add32(unsafeBitCast(i, Int32.self), UnsafeMutablePointer(p)))
}

@inline(__always) func Sub(i: Int32, p: UnsafeMutablePointer<Int32>) -> Int32
{
  return Sub32(i, p)
}

@inline(__always) func Sub(i: UInt32, p: UnsafeMutablePointer<UInt32>) -> UInt32
{
  return UInt32(bitPattern: Sub32(unsafeBitCast(i, Int32.self), UnsafeMutablePointer(p)))
}

@inline(__always) func Increment(p: UnsafeMutablePointer<Int32>) -> Int32
{
  return Increment32(p)
}

@inline(__always) func Increment(p: UnsafeMutablePointer<UInt32>) -> UInt32
{
  return UInt32(bitPattern: Increment32(UnsafeMutablePointer(p)))
}

@inline(__always) func Decrement(p: UnsafeMutablePointer<Int32>) -> Int32
{
  return Decrement32(p)
}

@inline(__always) func Decrement(p: UnsafeMutablePointer<UInt32>) -> UInt32
{
  return UInt32(bitPattern: Decrement32(UnsafeMutablePointer(p)))
}

// MARK: Int64 and UInt64 Atomics

@inline(__always) func Load(p: UnsafeMutablePointer<Int64>) -> Int64
{
  return Load64(p)
}

@inline(__always) func Load(p: UnsafeMutablePointer<UInt64>) -> UInt64
{
  return UInt64(bitPattern: Load64(UnsafeMutablePointer(p)))
}

@inline(__always) func SyncLoad(p: UnsafeMutablePointer<Int64>) -> Int64
{
  return SyncLoad64(p)
}

@inline(__always) func SyncLoad(p: UnsafeMutablePointer<UInt64>) -> UInt64
{
  return UInt64(bitPattern: SyncLoad64(UnsafeMutablePointer(p)))
}

@inline(__always) func Store(v: Int64, p: UnsafeMutablePointer<Int64>)
{
  Store64(v, p)
}

@inline(__always) func Store(v: UInt64, p: UnsafeMutablePointer<UInt64>)
{
  Store64(unsafeBitCast(v, Int64.self), UnsafeMutablePointer(p))
}

@inline(__always) func SyncStore(v: Int64, p: UnsafeMutablePointer<Int64>)
{
  SyncStore64(v, p)
}

@inline(__always) func SyncStore(v: UInt64, p: UnsafeMutablePointer<UInt64>)
{
  SyncStore64(unsafeBitCast(v, Int64.self), UnsafeMutablePointer(p))
}

@inline(__always) func Swap(v: Int64, p: UnsafeMutablePointer<Int64>) -> Int64
{
  return Swap64(v, p)
}

@inline(__always) func Swap(v: UInt64, p: UnsafeMutablePointer<UInt64>) -> UInt64
{
  return UInt64(bitPattern: Swap64(unsafeBitCast(v, Int64.self), UnsafeMutablePointer(p)))
}

@inline(__always) func Add(i: Int64, p: UnsafeMutablePointer<Int64>) -> Int64
{
  return Add64(i, p)
}

@inline(__always) func Add(i: UInt64, p: UnsafeMutablePointer<UInt64>) -> UInt64
{
  return UInt64(bitPattern: Add64(unsafeBitCast(i, Int64.self), UnsafeMutablePointer(p)))
}

@inline(__always) func Sub(i: Int64, p: UnsafeMutablePointer<Int64>) -> Int64
{
  return Sub64(i, p)
}

@inline(__always) func Sub(i: UInt64, p: UnsafeMutablePointer<UInt64>) -> UInt64
{
  return UInt64(bitPattern: Sub64(unsafeBitCast(i, Int64.self), UnsafeMutablePointer(p)))
}

@inline(__always) func Increment(p: UnsafeMutablePointer<Int64>) -> Int64
{
  return Increment64(p)
}

@inline(__always) func Increment(p: UnsafeMutablePointer<UInt64>) -> UInt64
{
  return UInt64(bitPattern: Increment64(UnsafeMutablePointer(p)))
}

@inline(__always) func Decrement(p: UnsafeMutablePointer<Int64>) -> Int64
{
  return Decrement64(p)
}

@inline(__always) func Decrement(p: UnsafeMutablePointer<UInt64>) -> UInt64
{
  return UInt64(bitPattern: Decrement64(UnsafeMutablePointer(p)))
}
