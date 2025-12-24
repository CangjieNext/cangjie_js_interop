/**
 * Created on 2025/3/6
 */
package ohos_app_cangjie_entry.js_interop

import std.sync.ReentrantMutex
import std.sync.AtomicInt64
import std.sync.AtomicBool

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
    private var destroyed: AtomicBool = AtomicBool(false)
    let contextCreatedLock = AtomicBool(false)

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
        let counter = AtomicInt64(1)
        uvLoop.postTask {
            result.value = JSRuntime(uvLoop)
            counter.store(0)
        }
        while (counter.load() != 0) {
        }
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
    }

    ~init() {
        if (!destroyed.compareAndSwap(false, true)) {
            return
        }

        let counter = AtomicInt64(1)
        uvLoop_.postTask {
            unsafe {
                if (let Some(context) <- mainContext_) {
                    check(OH_JSVM_DestroyEnv(context.env))
                }
                check(OH_JSVM_CloseVMScope(vm_, scope_))
                check(OH_JSVM_DestroyVM(vm_))
            }
            if (let Some(context) <- mainContext_) {
                context.destroyed = true
            }
            counter.store(0)
        }
        while (counter.load() != 0) {
        }

        uvLoop_.stop()
    }

    public func destroy(): Unit {
        if (!destroyed.compareAndSwap(false, true)) {
            return
        }

        let counter = AtomicInt64(1)
        uvLoop_.postTask {
            unsafe {
                if (let Some(context) <- mainContext_) {
                    check(OH_JSVM_DestroyEnv(context.env))
                }
                check(OH_JSVM_CloseVMScope(vm_, scope_))
                check(OH_JSVM_DestroyVM(vm_))
            }

            if (let Some(context) <- mainContext_) {
                context.destroyed = true
            }
            counter.store(0)
        }
        while (counter.load() != 0) {
        }
        uvLoop_.stop()
    }

    public func isDestroyed(): Bool {
        return destroyed.load()
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
                if (OH_JSVM_IsExceptionPending(context.env, inout isPending).isOk() && isPending) {
                    var error = JSVM_Value()
                    if (OH_JSVM_GetAndClearLastException(context.env, inout error).isOk()) {
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
                uvLoop_.postTask {
                    if (!contextCreatedLock.load()) {
                        createContext()
                        contextCreatedLock.store(true)
                    }
                }
                while (!contextCreatedLock.load()) {
                }
                return mainContext_.getOrThrow()
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
