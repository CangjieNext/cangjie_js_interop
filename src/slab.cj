// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package js_interop

import std.collection.ArrayList
import std.sync.AtomicInt64
import std.sync.AtomicInt8

struct AtomicLock {
    var value = AtomicInt8(0)

    mut func acquire<T>(lambda: () -> T): T {
        while (value.compareAndSwap(0, 1) == false) {}
        let result = lambda()
        value.store(0)
        return result
    }

    mut func lock(): Unit {
        while (value.compareAndSwap(0, 1) == false) {}
    }

    mut func unlock(): Unit {
        value.store(0)
    }
}

protected struct SlabItem<T> {
    SlabItem(
        var data: ?T,
        var prev: Int64
    ) {}
}

protected struct Slab<T> {
    private static var nextId_ = AtomicInt64(0)
    private static func nextId(): Int64 {
        let result = nextId_.fetchAdd(0x1_0000_0000)
        result
    }

    private let slabId_ = nextId()
    private var items_ = ArrayList<SlabItem<T>>()
    private var last_ = -1

    public init() {}

    private func toIndex(id: Int64): ?Int64 {
        if ((id & slabId_) != slabId_) {
            return None
        }
        id & 0xFFFFFFFF
    }

    private func toId(index: Int64): Int64 {
        if (index > 0xFFFFFFFF) {
            throw Exception("out of range: ${index}")
        }
        slabId_ | index
    }

    protected mut func getSlabItemsAndClear(): ArrayList<SlabItem<T>> {
        let items = items_
        items_ = ArrayList<SlabItem<T>>()
        last_ = -1
        return items
    }

    protected static func toDataList(items: ArrayList<SlabItem<T>>): ArrayList<T> {
        let result = ArrayList<T>()
        for (item in items) {
            if (let Some(data) <- item.data) {
                result.add(data)
            }
        }
        return result
    }

    public mut func getAllAndClear(): ArrayList<T> {
        let items = getSlabItemsAndClear()
        toDataList(items)
    }

    public mut func append(data: T): Int64 {
        if (last_ >= 0) {
            let lastPrev = items_[last_].prev
            let result = last_
            items_[last_] = SlabItem<T>(data, -1)
            last_ = lastPrev
            return toId(result)
        }
        let result = items_.size
        items_.add(SlabItem<T>(data, -1))
        return toId(result)
    }

    public mut func remove(id: Int64): ?T {
        let optIndex = toIndex(id)
        if (optIndex.isNone()) {
            return None
        }
        let index = optIndex.getOrThrow()
        if (index < 0 || index >= items_.size) {
            return None
        }
        if (let Some(data) <- items_[index].data) {
            items_[index] = SlabItem<T>(None, last_)
            last_ = index
            return data
        } else {
            return None
        }
    }

    public func get(id: Int64): ?T {
        let optIndex = toIndex(id)
        if (optIndex.isNone()) {
            return None
        }
        let index = optIndex.getOrThrow()
        if (index < 0 || index >= items_.size) {
            return None
        }
        if (let Some(data) <- items_[index].data) {
            return data
        } else {
            return None
        }
    }

    public operator func [](id: Int64): T {
        return get(id).getOrThrow()
    }
}

protected struct SlabMT<T> {
    var slab_ = Slab<T>()
    var mutex_: AtomicLock

    public init() {
        mutex_ = AtomicLock()
    }

    public mut func append(data: T): Int64 {
        mutex_.lock()
        let result = slab_.append(data)
        mutex_.unlock()
        return result
    }

    public mut func remove(id: Int64): ?T {
        mutex_.lock()
        let result = slab_.remove(id)
        mutex_.unlock()
        return result
    }

    public mut func get(id: Int64): ?T {
        mutex_.lock()
        let result = slab_.get(id)
        mutex_.unlock()
        return result
    }

    public mut operator func [](id: Int64): T {
        get(id).getOrThrow()
    }

    public mut func getAllAndClear(): ArrayList<T> {
        mutex_.lock()
        let items = slab_.getSlabItemsAndClear()
        mutex_.unlock()
        return Slab<T>.toDataList(items)
    }
}
