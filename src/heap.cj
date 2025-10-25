/**
 * Created on 2025/3/5
 */
package ohos_app_cangjie_entry.js_interop

abstract sealed class JSHeapObject <: ToJSValue {
    protected let context_: JSContext
    let ref_: JSVM_Ref

    protected init(context: JSContext, value: JSValue) {
        context_ = context
        unsafe {
            var ref = JSVM_Ref()
            JSRuntime.check(OH_JSVM_CreateReference(context.env, value.value_, 1, inout ref))
            ref_ = ref
        }
    }

    static func releaseRefs(env: JSVM_Env, refs: Array<JSVM_Ref>): Unit {
        for (ref in refs) {
            unsafe {
                JSRuntime.check(OH_JSVM_DeleteReference(env, ref))
            }
        }
    }

    public func toJSValue(): JSValue {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_GetReferenceValue(context_.env, ref_, inout result))
            return JSValue(context_, result)
        }
    }

    public func toJSValue(_: JSContext): JSValue {
        return toJSValue()
    }

    prop innerValue: JSVM_Value {
        get() {
            toJSValue().value_
        }
    }
}
