// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package js_interop

public class JSMap <: JSHeapObject {
    protected init(context: JSContext, value: JSValue) {
        super(context, value)
    }

    ~init() {
        context_.releaseRef(ref_)
    }

    public func hasProperty(key: ToJSValue): Bool {
        let jsKey = key.toJSValue(context_).value_
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_HasProperty(context_.env, innerValue, jsKey, inout result))
            return result
        }
    }

    public func deleteProperty(key: ToJSValue): Bool {
        let jsKey = key.toJSValue(context_).value_
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_DeleteProperty(context_.env, innerValue, jsKey, inout result))
            return result
        }
    }

    public func keys(): JSArray {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_GetAllPropertyNames(context_.env, innerValue, JSVM_KeyCollectionMode.JSVM_KEY_OWN_ONLY,
                JSVM_KeyFilter.ALL_PROPERTIES, JSVM_KeyConversion.JSVM_KEY_KEEP_NUMBERS, inout result))
            return JSArray(context_, JSValue(context_, result))
        }
    }

    public prop size: Int64 {
        get() {
            return keys().size
        }
    }

    public operator func [](key: ToJSValue): JSValue {
        let jsKey = key.toJSValue(context_).value_
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_GetProperty(context_.env, innerValue, jsKey, inout result))
            return JSValue(context_, result)
        }
    }

    public operator func [](key: ToJSValue, value!: ToJSValue): Unit {
        let jsKey = key.toJSValue(context_).value_
        let jsVal = value.toJSValue(context_).value_
        unsafe {
            JSRuntime.check(OH_JSVM_SetProperty(context_.env, innerValue, jsKey, jsVal))
        }
    }
}
