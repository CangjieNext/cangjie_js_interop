/**
 * Created on 2025/3/6
 */
package ohos_app_cangjie_entry.js_interop

public struct JSCallInfo {
    JSCallInfo(
        public let args: Array<JSValue>,
        public let thisArg: JSValue,
        let lambdaId: Int64
    ) {}

    static func parseCallInfo(context: JSContext, cbInfo: JSVM_CallbackInfo): JSCallInfo {
        var argPreserve = Array<JSVM_Value>(256, repeat: JSVM_Value())
        var argC = argPreserve.size
        var thisArg = JSVM_Value()
        var lambdaId: Int64 = 0
        unsafe {
            let handle = acquireArrayRawData(argPreserve)
            try {
                JSRuntime.check(OH_JSVM_GetCbInfo(context.env, cbInfo, inout argC, handle.pointer, inout thisArg, inout lambdaId))
                releaseArrayRawData(handle)
            } catch (e: Exception) {
                releaseArrayRawData(handle)
                throw e
            } catch (e: Error) {
                releaseArrayRawData(handle)
                throw e
            }
        }
        let imutableArgs = argPreserve
        let args = Array<JSValue>(argC) {
            idx => JSValue(context, imutableArgs[idx])
        }
        return JSCallInfo(args, JSValue(context, thisArg), lambdaId)
    }

    public prop size: Int64 {
        get() {
            return args.size
        }
    }

    public operator func [](index: Int64): JSValue {
        return args[index]
    }
}

public type JSLambda = (JSContext, JSCallInfo) -> JSValue

func throwExceptionToJS(env: JSVM_Env, info: String, stack: Array<StackTraceElement>): Unit {
    let stackTexts = Array<String>(stack.size) {
        index =>
        let frame = stack[index]
        let packageDelimiter = if (frame.declaringClass.isEmpty()) { "" } else { "." }
        "\t at ${frame.declaringClass}${packageDelimiter}${frame.methodName}(${frame.fileName}:${frame.lineNumber})"
    }
    let message = "Cangjie ${info}\n${String.join(stackTexts, delimiter: "\n")}"
    unsafe {
        let msg = LibC.mallocCString(message)
        OH_JSVM_ThrowError(env, CString(CPointer<UInt8>()), msg)
        LibC.free(msg)
    }
}

@C
func jsFunctionCallbackStub(env: JSVM_Env, info: JSVM_CallbackInfo): JSVM_Value {
    let context = JSContext.getContext(env)
    context.newScope {
        let cbInfo = JSCallInfo.parseCallInfo(context, info)
        try {
            let fun = context.sharedLambda_.get(cbInfo.lambdaId).getOrThrow()
            let result = fun(context, cbInfo)
            return result.value_
        } catch (exception: Exception) {
            throwExceptionToJS(env, exception.toString(), exception.getStackTrace())
            return context.undefined().value_
        } catch (error: Error) {
            throwExceptionToJS(env, error.toString(), error.getStackTrace())
            return context.undefined().value_
        }
    }
}

@C
func jsFunctionFinalizerStub(env: JSVM_Env, data: CPointer<Unit>, hint: Int64): Unit {
    let context = JSContext.getContext(env)
    if (let Some(f) <- context.sharedLambda_.remove(hint)) {
        unsafe {
            LibC.free(data)
        }
    }
}

public class JSFunction <: JSHeapObject & FromJSValue<JSFunction> {
    protected init(context: JSContext, value: JSValue) {
        super(context, value)
    }

    ~init() {
        context_.releaseRef(ref_)
    }

    public static func fromJSValue(_: JSContext, value: JSValue): JSFunction {
        return value.asFunction()
    }

    public static func isCurrentType(_: JSContext, value: JSValue): Bool {
        return value.isFunction()
    }

    static func createFunc(context: JSContext, lambda: JSLambda): JSFunction {
        let lambdaId = context.sharedLambda_.append(lambda)
        var cb = JSVM_Callback(jsFunctionCallbackStub, lambdaId)
        unsafe {
            var result = JSVM_Value()
            var callback = LibC.malloc<JSVM_Callback>()
            callback.write(cb)
            JSRuntime.check(OH_JSVM_CreateFunction(context.env, CPointer<UInt8>(), 0, callback, inout result))
            JSRuntime.check(OH_JSVM_AddFinalizer(context.env, result, CPointer<Unit>(callback), jsFunctionFinalizerStub, lambdaId, CPointer<JSVM_Ref>()))
            return JSFunction(context, JSValue(context, result))
        }
    }

    static func createFunc(context: JSContext, lambda: JSLambda, name: String): JSFunction {
        let lambdaId = context.sharedLambda_.append(lambda)
        var cb = JSVM_Callback(jsFunctionCallbackStub, lambdaId)
        unsafe {
            let handle = acquireArrayRawData(name.rawData())
            var result = JSVM_Value()
            try {
                var callback = LibC.malloc<JSVM_Callback>()
                callback.write(cb)
                JSRuntime.check(OH_JSVM_CreateFunction(context.env, handle.pointer, handle.array.size, callback, inout result))
                JSRuntime.check(OH_JSVM_AddFinalizer(context.env, result, CPointer<Unit>(callback), jsFunctionFinalizerStub, lambdaId, CPointer<JSVM_Ref>()))
                releaseArrayRawData(handle)
            } catch (e: Exception) {
                releaseArrayRawData(handle)
                throw e
            } catch (e: Error) {
                releaseArrayRawData(handle)
                throw e
            }
            return JSFunction(context, JSValue(context, result))
        }
    }

    public func call(thisArg: JSValue, args: Array<ToJSValue>): JSValue {
        let result = innerCall(thisArg.value_, Array<JSVM_Value>(args.size) {
            idx => args[idx].toJSValue(context_).value_
        })
        return JSValue(context_, result)
    }

    public func globalCall(args: Array<ToJSValue>): JSValue {
        return call(context_.undefined(), args)
    }

    func innerCall(thisArg: JSVM_Value, args: Array<JSVM_Value>): JSVM_Value {
        unsafe {
            var result = JSVM_Value()
            if (args.isEmpty()) {
                JSRuntime.checkAndHandleError(context_, OH_JSVM_CallFunction(context_.env, thisArg, toJSValue().value_, 0, CPointer<JSVM_Value>(), inout result))
            } else {
                let handle = acquireArrayRawData(args)
                try {
                    JSRuntime.checkAndHandleError(context_, OH_JSVM_CallFunction(context_.env, thisArg, toJSValue().value_, args.size, handle.pointer, inout result))
                    releaseArrayRawData(handle)
                } catch (e: Exception) {
                    releaseArrayRawData(handle)
                    throw e
                } catch (e: Error) {
                    releaseArrayRawData(handle)
                    throw e
                }
            }

            return result
        }
    }
}
