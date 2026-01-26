// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package js_interop

import std.sync.AtomicInt32
import std.sync.AtomicBool
import std.sync.AtomicInt64

type uv_thread_t = UIntNative

@C struct uv_loop_t {}
type uv_loop = CPointer<uv_loop_t>

@C struct uv_async_t {
    uv_async_t(
        let data: UIntNative,
        let reserved: VArray<UInt8, $120>
    ) {}
}
type uv_async = CPointer<uv_async_t>

@C
struct uv_run_mode {
    uv_run_mode(let value: UInt32) {}

    static let DEFAULT = uv_run_mode(0)
    static let ONCE = uv_run_mode(1)
    static let NO_WAIT = uv_run_mode(2)
}

foreign {
    func uv_thread_create(tid: CPointer<uv_thread_t>, entry: CFunc<(Int64) -> Unit>, hint: Int64): Int32
    func uv_thread_self(): uv_thread_t
    func uv_thread_join(tid: CPointer<uv_thread_t>): Int32
    func uv_loop_new(): uv_loop
    func uv_run(loop: uv_loop, mode: uv_run_mode): Int32
    func uv_stop(loop: uv_loop): Unit
    func uv_async_init(loop: uv_loop, async: uv_async, callback: CFunc<(uv_async) -> Unit>): Int32
    func uv_async_send(async: uv_async): Int32
    func uv_close(async: uv_async, callback: CFunc<(uv_async) -> Unit>): Unit
    func uv_walk(loop: uv_loop, callback: CFunc<(uv_async, CPointer<Unit>) -> Unit>, data: CPointer<Unit>): Unit
    func uv_is_closing(async: uv_async): Int32
    func uv_loop_close(loop: uv_loop): Int32
}

@C
func uvLoopRunStub(id: Int64): Unit {
    if (let Some(loop) <- UvLoop.allLoops_.get(id)) {
        if (!loop.destroyed.load()) {
            loop.onStart()
        }
    }
}

@C
func uvLoopAsyncStub(async: uv_async): Unit {
    let id = unsafe {
        Int64(CPointer<UIntNative>(async).read())
    }
    if (let Some(loop) <- UvLoop.allLoops_.get(id)) {
        loop.onAsync()
    }
}

class UvLoop {
    static var allLoops_ = SlabMT<UvLoop>()

    public var destroyed = AtomicBool(false)

    static func newLoop(): UvLoop {
        let loop = UvLoop()
        let index = allLoops_.append(loop)
        loop.setIndex(index)
        var tid: uv_thread_t = 0
        let status = unsafe { uv_thread_create(inout tid, uvLoopRunStub, index) }
        if (status != 0) {
            throw Exception("create uv_thread failed: ${status}")
        }
        while (loop.runStatus_.load() == 0) {
        }
        return loop
    }

    private let loop_: uv_loop
    public var tid_: uv_thread_t
    private let async_: uv_async

    // 0: Starting
    // 1: Running
    // 2: Stopping
    // 3: Stopped
    private var runStatus_ = AtomicInt32(0)
    // 0: Idle
    // 1: Requesting
    private var asyncStatus_ = AtomicInt32(0)

    private var pendingTasks_ = SlabMT<() -> Unit>()

    init() {
        tid_ = 0
        unsafe {
            loop_ = uv_loop_new()
            async_ = LibC.malloc<uv_async_t>()
            let status = uv_async_init(loop_, async_, uvLoopAsyncStub)
            if (status != 0) {
                throw Exception("failed to init async: ${status}")
            }
        }
    }

    public func stop(): Unit {
        var curStatus: Int32 = 0
        do {
            curStatus = runStatus_.load()
            if (curStatus >= 2) {
                return
            }
        } while (!runStatus_.compareAndSwap(curStatus, 2))

        let currentTid = unsafe { uv_thread_self() }
        if (tid_ == currentTid) {
            throw Exception("can't stop uv loop on it's running thread")
        }
        closeHandles()
        allLoops_.remove(getIndex())
        unsafe {
            uv_stop(loop_)
            uv_close(async_) {
                item => ()
            }
            var tid = tid_
            uv_thread_join(inout tid)
        }
        runStatus_.store(3)
    }

    func setIndex(value: Int64): Unit {
        unsafe {
            CPointer<UIntNative>(async_).write(UIntNative(value))
        }
    }

    func getIndex(): Int64 {
        let id = unsafe {
            Int64(CPointer<UIntNative>(async_).read())
        }
        id
    }

    public func postTask(task: () -> Unit): Unit {
        pendingTasks_.append(task)
        var index = 3
        if (asyncStatus_.compareAndSwap(0, 1)) {
            var status = unsafe {
                uv_async_send(async_)
            }
            while (status != 0 && index > 0) {
                status = unsafe {uv_async_send(async_)}
                index = index - 1
            }
            if (status != 0) {
                asyncStatus_.store(0)
            }
        }
    }

    func onStart(): Unit {
        unsafe {
            tid_ = uv_thread_self()
            postTask {
                runStatus_.store(1)
            }
            uv_run(loop_, uv_run_mode.DEFAULT)
            uv_loop_close(loop_)
        }
    }

    func onAsync(): Unit {
        asyncStatus_.store(0)
        let tasks = pendingTasks_.getAllAndClear()
        for (task in tasks) {
            if (!this.destroyed.load()) {
                task()
            }
        }
    }

    prop currentTid: uv_thread_t {
        get() {
            unsafe { uv_thread_self() }
        }
    }

    public func isOnRunningThread(): Bool {
        return tid_ == currentTid
    }

    public func destroy(mainContext_: ?JSContext, vm_: JSVM_VM, scope_: JSVM_VMScope): Unit {
        let counter = AtomicInt64(1)
        postTask {
            unsafe {
                if (let Some(context) <- mainContext_) {
                    let res = context.removeCtx()
                    if (res.isNone()) {
                        JSLOG.error("removeCtx failed.")
                    }
                    JSRuntime.check(OH_JSVM_CloseEnvScope(context.env, context.envScope))
//                    JSRuntime.check(OH_JSVM_SetDebugOption(context.env, JSVM_DebugOption.JSVM_SCOPE_CHECK, false))
                    JSRuntime.check(OH_JSVM_DestroyEnv(context.env))
                    context.destroyed.store(true)
                }
                JSRuntime.check(OH_JSVM_CloseVMScope(vm_, scope_))
                JSRuntime.check(OH_JSVM_DestroyVM(vm_))
            }
            counter.store(0)
        }
        while (counter.load() != 0) {
        }
        stop()
    }

    private func closeHandles(): Unit {
        let counter = AtomicInt64(1)
        postTask {
            unsafe {
                uv_walk(loop_, {
                    handler, arg => if (uv_is_closing(handler) == 0) {
                        uv_close(handler) {
                            handler => ()
                        }
                    }
                }, CPointer<Unit>())
            }
            counter.store(0)
            destroyed.store(true);
        }
        while (counter.load() != 0) {
        }
    }
}