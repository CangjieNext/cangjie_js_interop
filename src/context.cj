// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package js_interop

import std.collection.*
import std.sync.AtomicInt64


public class JSContext {
    private static let allContext_ = HashMap<UIntNative, JSContext>()
    private static var mutex_ = AtomicLock()
    var destroyed = false

    JSContext(
        private let env_: JSVM_Env,
        private let loop_: UvLoop
    ) {
        // startAsync()
    }

    prop env: JSVM_Env {
        get() {
            // checkScope()
            if (destroyed) {
                throw Exception("Contex has been destroyed!")
            }
            env_
        }
    }

    static func createContext(env: JSVM_Env, loop: UvLoop): JSContext {
        let key = env.toUIntNative()
        mutex_.acquire {
            if (let Some(ctx) <- allContext_.get(key)) {
                return ctx
            } else {
                let ctx = JSContext(env, loop)
                allContext_.add(key, ctx)
                return ctx
            }
        }
    }

    static func getContext(env: JSVM_Env): JSContext {
        let key = env.toUIntNative()
        mutex_.acquire {
            allContext_[key]
        }
    }

    static func removeContext(env: JSVM_Env): ?JSContext {
        let key = env.toUIntNative()
        mutex_.acquire {
            return allContext_.remove(key)
        }
    }

    var sharedLambda_ = Slab<JSLambda>()
    var asyncCallbacks_ = SlabMT<() -> Unit>()
    let toDeleteRefs_ = ArrayList<JSVM_Ref>()
    var refsMutex_ = AtomicLock()

    func doAsyncTask(): Unit {
        let callbacks = asyncCallbacks_.getAllAndClear()
        for (callback in callbacks) {
            if (this.destroyed) {
                return
            }
            callback()
        }
        let refs = refsMutex_.acquire {
            let result = toDeleteRefs_.toArray()
            toDeleteRefs_.clear()
            result
        }
        newScope { JSHeapObject.releaseRefs(env, refs) }
    }

    private func startAsync(): Unit {
        newScope {
            // missing global func setInterval, startAsync is not available.
            let setInterval = global["setInterval"].asFunction()
            let callback = function { _, callInfo =>
                doAsyncTask()
                undefined()
            }
            setInterval.globalCall(callback, 20)
        }
    }

    func releaseRef(ref: JSVM_Ref): Unit {
        refsMutex_.acquire {
            toDeleteRefs_.add(ref)
        }
    }

    func postJSTask(task: () -> Unit): Unit {
        asyncCallbacks_.append(task)
        loop_.postTask {
            doAsyncTask()
        }
    }

    var scopeDepth_ = 0
    private func createScopes<T>(task: () -> T): T {
        unsafe {
            var envScope = JSVM_EnvScope()
            var handleScope = JSVM_HandleScope()
            scopeDepth_++
            JSRuntime.check(OH_JSVM_OpenEnvScope(env, inout envScope))
            JSRuntime.check(OH_JSVM_OpenHandleScope(env, inout handleScope))
            var result: ?T = None
            try {
                result = task()
            } catch (e: Exception) {
                JSRuntime.check(OH_JSVM_CloseHandleScope(env, handleScope))
                JSRuntime.check(OH_JSVM_CloseEnvScope(env, envScope))
                scopeDepth_--
                throw e
            } catch (e: Error) {
                JSRuntime.check(OH_JSVM_CloseHandleScope(env, handleScope))
                JSRuntime.check(OH_JSVM_CloseEnvScope(env, envScope))
                scopeDepth_--
                throw e
            }
            JSRuntime.check(OH_JSVM_CloseHandleScope(env, handleScope))
            JSRuntime.check(OH_JSVM_CloseEnvScope(env, envScope))
            scopeDepth_--
            return result.getOrThrow()
        }
    }

    func checkScope(): Unit {
        if (scopeDepth_ <= 0) {
            throw Exception("Create a scope first!")
        }
    }

    public func newScope<T>(task: () -> T): T {
        if (loop_.isOnRunningThread()) {
            return createScopes(task)
        } else {
            let result = Box<?T>(None)
            let message = Box<?String>(None)
            let counter = AtomicInt64(1)
            postJSTask {
                try {
                    result.value = createScopes(task)
                } catch (e: Exception) {
                    message.value = e.message
                    counter.store(0)
                    throw e
                } catch (e: Error) {
                    message.value = e.message
                    counter.store(0)
                    throw e
                }
                counter.store(0)
            }
            while (counter.load() != 0) {
            }
            match (message.value) {
                case Some(v) => throw Exception(v)
                case None => return result.value.getOrThrow()
            }
        }
    }

    public prop global: JSObject {
        get() {
            unsafe {
                var result = JSVM_Value()
                JSRuntime.check(OH_JSVM_GetGlobal(env, inout result))
                return JSObject(this, JSValue(this, result))
            }
        }
    }

    public func undefined(): JSValue {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_GetUndefined(env, inout result))
            return JSValue(this, result)
        }
    }

    public func boolean(value: Bool): JSValue {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_GetBoolean(env, value, inout result))
            return JSValue(this, result)
        }
    }

    public func number(value: Int32): JSValue {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_CreateInt32(env, value, inout result))
            return JSValue(this, result)
        }
    }

    public func number(value: UInt32): JSValue {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_CreateUint32(env, value, inout result))
            return JSValue(this, result)
        }
    }

    public func number(value: Int64): JSValue {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_CreateInt64(env, value, inout result))
            return JSValue(this, result)
        }
    }

    public func number(value: Float64): JSValue {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_CreateDouble(env, value, inout result))
            return JSValue(this, result)
        }
    }

    public func string(value: String): JSString {
        unsafe {
            var result = JSVM_Value()
            let cstr = LibC.mallocCString(value)
            JSRuntime.check(OH_JSVM_CreateStringUtf8(env, cstr, value.size, inout result))
            LibC.free(cstr)
            return JSString(this, JSValue(this, result))
        }
    }

    public func object(): JSObject {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_CreateObject(env, inout result))
            return JSObject(this, JSValue(this, result))
        }
    }

    public func object(properties: Array<(JSKeyable, ToJSValue)>): JSObject {
        let result = object()
        for ((k, v) in properties) {
            result[k] = v
        }
        return result
    }

    public func function(lambda: JSLambda): JSFunction {
        return JSFunction.createFunc(this, lambda)
    }

    public func function(name: String, lambda: JSLambda): JSFunction {
        return JSFunction.createFunc(this, lambda, name)
    }

    public func array(): JSArray {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_CreateArray(env, inout result))
            return JSArray(this, JSValue(this, result))
        }
    }

    // TODO: wrap these in C code to reduce C-call numbers.
    public func array(data: Array<ToJSValue>): JSArray {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_CreateArrayWithLength(env, data.size, inout result))
            let jsArray = JSArray(this, JSValue(this, result))
            for (i in 0..data.size) {
                jsArray[i] = data[i]
            }
            return jsArray
        }
    }

    public func map(): JSMap {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_CreateMap(env, inout result))
            return JSMap(this, JSValue(this, result))
        }
    }

    public func map(pairs: Array<(ToJSValue, ToJSValue)>): JSMap {
        let result = map()
        for ((k, v) in pairs) {
            result[k] = v
        }
        return result
    }

    public func script(src: String): JSScriptBuilder {
        return JSScriptBuilder(this, src)
    }

    public func runScript(script: JSScript): JSValue {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_RunScript(env, script.script_, inout result))
            return JSValue(this, result)
        }
    }

    public func evaluate(src: String, codeCache!: JSCodeCache = JSCodeCache()): JSValue {
        let code = string(src).toJSValue()
        var rejected = false
        var script = JSVM_Script()
        var result = JSVM_Value()
        unsafe {
            JSRuntime.checkAndHandleError(this, OH_JSVM_CompileScript(env, code.value_, codeCache.data, codeCache.length, true, inout rejected, inout script))
            JSRuntime.checkAndHandleError(this, OH_JSVM_RunScript(env, script, inout result))
            return JSValue(this, result)
        }
    }

    public func garbageCollect() {
        unsafe {
            JSRuntime.check(OH_JSVM_MemoryPressureNotification(env, JSVM_MemoryPressureLevel.CRITICAL))
        }
    }
}
