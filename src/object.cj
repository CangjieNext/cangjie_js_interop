// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package js_interop

sealed interface JSKeyable <: ToString {}

extend String <: JSKeyable & ToJSValue {
    public func toJSValue(context: JSContext): JSValue {
        context.string(this).toJSValue()
    }
}

extend Int64 <: JSKeyable & ToJSValue {
    public func toJSValue(context: JSContext): JSValue {
        return context.number(this)
    }
}

public class JSObject <: JSHeapObject {
    static func keyToJS(context: JSContext, key: JSKeyable): JSVM_Value {
        match (key) {
            case value: String => context.string(value).toJSValue().value_
            case value: Int64 => context.number(value).value_
            case jStr: JSString => jStr.innerValue
            case _ => throw Exception("unsupported key: ${key}")
        }
    }

    protected init(context: JSContext, value: JSValue) {
        super(context, value)
    }

    ~init() {
        context_.releaseRef(ref_)
    }

    public func hasProperty(key: JSKeyable): Bool {
        let jsKey = keyToJS(context_, key)
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_HasProperty(context_.env, innerValue, jsKey, inout result))
            return result
        }
    }

    public func deleteProperty(key: JSKeyable): Bool {
        let jsKey = keyToJS(context_, key)
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_DeleteProperty(context_.env, innerValue, jsKey, inout result))
            return result
        }
    }

    public func getPropertyNames(): JSArray {
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_GetAllPropertyNames(context_.env, innerValue, JSVM_KeyCollectionMode.JSVM_KEY_OWN_ONLY,
                JSVM_KeyFilter.ALL_PROPERTIES, JSVM_KeyConversion.JSVM_KEY_KEEP_NUMBERS, inout result))
            return JSArray(context_, JSValue(context_, result))
        }
    }

    public prop size: Int64 {
        get() {
            return getPropertyNames().size
        }
    }

    public operator func [](key: JSKeyable): JSValue {
        let jsKey = keyToJS(context_, key)
        unsafe {
            var result = JSVM_Value()
            JSRuntime.check(OH_JSVM_GetProperty(context_.env, innerValue, jsKey, inout result))
            return JSValue(context_, result)
        }
    }

    public operator func [](key: JSKeyable, value!: ToJSValue): Unit {
        let jsKey = keyToJS(context_, key)
        let jsVal = value.toJSValue(context_).value_
        unsafe {
            JSRuntime.check(OH_JSVM_SetProperty(context_.env, innerValue, jsKey, jsVal))
        }
    }
}
