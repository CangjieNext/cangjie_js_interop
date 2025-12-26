// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package js_interop

import std.sync.ReentrantMutex
import std.sync.SyncCounter

class Once<T> {
    private let mutex_ = ReentrantMutex()
    private var task_: ?() -> T
    private var data_: ?T = None

    init(task: () -> T) {
        task_ = task
    }

    prop value: T {
        get() {
            synchronized(mutex_) {
                if (let Some(data) <- data_) {
                    data
                } else {
                    let data = task_.getOrThrow()()
                    task_ = None
                    data_ = data
                    data
                }
            }
        }
    }

    func execute() {
        value
    }
}

public class JSRuntime {
    private let vm_: JSVM_VM
    private var mainContext_: ?JSContext = None
    private var uvLoop_: UvLoop
    private var scope_: JSVM_VMScope
    private var destroyed: Bool

    private static let JSVMGlobalInitTask = Once {
        var options = JSVM_InitOptions()
        unsafe {
            check(OH_JSVM_Init(inout options))
        }
    }

    public static func create(): JSRuntime {
        JSVMGlobalInitTask.execute()
        let uvLoop = UvLoop.newLoop()
        let result = Box<?JSRuntime>(None)
        let counter = SyncCounter(1)
        uvLoop.postTask {
            result.value = JSRuntime(uvLoop)
            counter.dec()
        }
        counter.waitUntilZero()
        return result.value.getOrThrow()
    }

    private init(loop: UvLoop) {
        uvLoop_ = loop

        var vm = CPointer<JSVM_VM__>()
        var scope = JSVM_VMScope()
        unsafe {
            var options = JSVM_CreateVMOptions()
            check(OH_JSVM_CreateVM(inout options, inout vm))
            check(OH_JSVM_OpenVMScope(vm, inout scope))
        }
        vm_ = vm
        scope_ = scope

        destroyed = false
    }

    ~init() {
        if (destroyed) { return }
        unsafe {
            check(OH_JSVM_CloseVMScope(vm_, scope_))
            check(OH_JSVM_DestroyVM(vm_))
        }
        uvLoop_.stop()
    }

    public func destroy(): Unit {
        if (destroyed) { return }
        unsafe {
            check(OH_JSVM_CloseVMScope(vm_, scope_))
            check(OH_JSVM_DestroyVM(vm_))
        }
        uvLoop_.stop()
        destroyed = true
    }

    public func isDestroyed(): Bool {
        return destroyed
    }

    // This will be replaced by `checkAndHandleError`.
    static func check(status: JSVM_Status): Unit {
        if (!status.isOk()) {
            throw Exception(status.toString())
        }
    }

    static func checkAndHandleError(context: JSContext, status: JSVM_Status): Unit {
        if (!status.isOk()) {
            unsafe {
                var isPending = false
                if (OH_JSVM_IsExceptionPending(context.env, inout isPending).isOk() && isPending)
                {
                    var error = JSVM_Value()
                    if (OH_JSVM_GetAndClearLastException(context.env, inout error).isOk())
                    {
                        // 获取异常堆栈
                        var stack = JSVM_Value()
                        let stackStr = LibC.mallocCString("stack")
                        OH_JSVM_GetNamedProperty(context.env, error, stackStr, inout stack)
                        LibC.free(stackStr)

                        throw Exception(JSValue(context, stack).asString().toString())
                    }
                }
            }

            throw Exception(status.toString())
        }
    }

    public prop mainContext: JSContext {
        get() {
            if (let Some(context) <- mainContext_) {
                context
            } else {
                createContext()
            }
        }
    }

    private func createContext(): JSContext {
        var env = JSVM_Env()
        unsafe {
            check(OH_JSVM_CreateEnv(vm_, 0, CPointer<JSVM_PropertyDescriptor>(), inout env))
        }
        let result = JSContext.createContext(env, uvLoop_)
        mainContext_ = result
        return result
    }

    public func getHeapStat(): JSVM_HeapStatistics {
        var result = JSVM_HeapStatistics()
        unsafe { check(OH_JSVM_GetHeapStatistics(vm_, inout result)) }
        return result
    }
}
