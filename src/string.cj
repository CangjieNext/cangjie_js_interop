// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package js_interop

public class JSString <: JSHeapObject & JSKeyable & FromJSValue<JSString> & ToString {
    init(context: JSContext, value: JSValue) {
        super(context, value)
    }

    ~init() {
        context_.releaseRef(ref_)
    }

    public static func isCurrentType(_: JSContext, value: JSValue): Bool {
        return value.isString()
    }

    public static func fromJSValue(_: JSContext, value: JSValue): JSString {
        return value.asString()
    }

    public func toString(): String {
        unsafe {
            var size = 0
            JSRuntime.check(OH_JSVM_GetValueStringUtf8(context_.env, innerValue, CPointer<UInt8>(), 0, inout size))
            size++  // Increase one because the null terminator is excluded.
            let buffer = Array<UInt8>(size, repeat: 0)
            let handle = acquireArrayRawData(buffer)
            try {
                JSRuntime.check(OH_JSVM_GetValueStringUtf8(context_.env, innerValue, handle.pointer, size, inout size))
                releaseArrayRawData(handle)
                return String.fromUtf8Unchecked(buffer[..size])  // Remove the null terminator.
            } catch (e: Exception) {
                releaseArrayRawData(handle)
                throw e
            } catch (e: Error) {
                releaseArrayRawData(handle)
                throw e
            }

        }
    }
}
