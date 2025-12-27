// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package js_interop

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
