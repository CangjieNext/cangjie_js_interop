/**
 * Created on 2025/3/5
 */
package ohos_app_cangjie_entry.js_interop

// Represents `undefined` type in JS.
public class JSUndefined {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

// Represents `null` type in JS.
public class JSNull {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

// Represents `boolean` type in JS.
public class JSBoolean {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }

    public func toBool(): Bool {
        value.toBoolean()
    }
}

// Represents `number` type in JS.
public class JSNumber {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }

    public func toInt32(): Int32 {
        value.toNumberInt32()
    }

    public func toUint32(): UInt32 {
        value.toNumberUint32()
    }

    public func toInt64(): Int64 {
        value.toNumberInt64()
    }

    public func toFloat64(): Float64 {
        value.toNumberFloat64()
    }
}

// Represents `symbol` type in JS.
public class JSSymbol {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

// Represents `external` type in JS.
public class JSExternal {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

// Represents `bigint` type in JS.
public class JSBigInt {
    let value: JSValue

    init(value: JSValue) {
        this.value = value
    }

    public func toJSValue(): JSValue {
        value
    }
}

public interface ToJSValue {
    func toJSValue(context: JSContext): JSValue
}

public interface FromJSValue<T> {
    static func fromJSValue(context: JSContext, src: JSValue): T
    static func isCurrentType(context: JSContext, src: JSValue): Bool
}

public class JSValue <: ToJSValue & FromJSValue<JSValue> {
    let context_: JSContext
    let value_: JSVM_Value

    init(context: JSContext, value: JSVM_Value) {
        context_ = context
        value_ = value
    }

    public func typeof(): JSVM_ValueType {
        unsafe {
            var result = JSVM_ValueType.UNDEFINED
            JSRuntime.check(OH_JSVM_Typeof(context_.env, value_, inout result))
            return result
        }
    }

    public func isUndefined(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsUndefined(context_.env, value_, inout result))
            return result
        }
    }

    public func isNull(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsNull(context_.env, value_, inout result))
            return result
        }
    }

    public func isNullOrUndefined(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsNullOrUndefined(context_.env, value_, inout result))
            return result
        }
    }

    public func isBoolean(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsBoolean(context_.env, value_, inout result))
            return result
        }
    }

    public func isNumber(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsNumber(context_.env, value_, inout result))
            return result
        }
    }

    public func isString(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsString(context_.env, value_, inout result))
            return result
        }
    }

    public func isSymbol(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsSymbol(context_.env, value_, inout result))
            return result
        }
    }

    public func isObject(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsObject(context_.env, value_, inout result))
            return result
        }
    }

    public func isFunction(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsFunction(context_.env, value_, inout result))
            return result
        }
    }

    public func isExternal(): Bool {
        // Strangely `OH_JSVM_IsExternal` is not provided in JSVM-API.
        typeof() == JSVM_ValueType.EXTERNAL
    }

    public func isBigInt(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsBigInt(context_.env, value_, inout result))
            return result
        }
    }

    public func isArray(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsArray(context_.env, value_, inout result))
            return result
        }
    }

    public func isMap(): Bool {
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_IsMap(context_.env, value_, inout result))
            return result
        }
    }

    public func asUndefined(): JSUndefined {
        if (!isUndefined()) {
            throw Exception("require undefined type but get ${typeof().toString()}")
        }
        JSUndefined(this)
    }

    public func asNull(): JSNull {
        if (!isNull()) {
            throw Exception("require null type but get ${typeof().toString()}")
        }
        JSNull(this)
    }

    public func asBoolean(): JSBoolean {
        if (!isBoolean()) {
            throw Exception("require boolean type but get ${typeof().toString()}")
        }
        JSBoolean(this)
    }

    public func asNumber(): JSNumber {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        JSNumber(this)
    }

    public func asString(): JSString {
        if (!isString()) {
            throw Exception("require string")
        }
        JSString(context_, this)
    }

    public func asSymbol(): JSSymbol {
        if (!isSymbol()) {
            throw Exception("require symbol type but get ${typeof().toString()}")
        }
        JSSymbol(this)
    }

    public func asObject(): JSObject {
        if (!isObject()) {
            throw Exception("require object type but get ${typeof().toString()}")
        }
        JSObject(context_, this)
    }

    public func asFunction(): JSFunction {
        if (!isFunction()) {
            throw Exception("requires function type but get ${typeof().toString()}")
        }
        return JSFunction(context_, this)
    }

    public func asExternal(): JSExternal {
        if (!isExternal()) {
            throw Exception("require external type but get ${typeof().toString()}")
        }
        JSExternal(this)
    }

    public func asBigInt(): JSBigInt {
        if (!isBigInt()) {
            throw Exception("require bigint type but get ${typeof().toString()}")
        }
        JSBigInt(this)
    }

    public func asArray(): JSArray {
        if (!isArray()) {
            throw Exception("requires array type but get ${typeof().toString()}")
        }
        return JSArray(context_, this)
    }

    public func asMap(): JSMap {
        if (!isMap()) {
            throw Exception("requires map type but get ${typeof().toString()}")
        }
        return JSMap(context_, this)
    }

    public func toBoolean(): Bool {
        if (!isBoolean()) {
            throw Exception("require boolean type but get ${typeof().toString()}")
        }
        unsafe {
            var result = false
            JSRuntime.check(OH_JSVM_GetValueBool(context_.env, value_, inout result))
            return result
        }
    }

    public func toNumberInt32(): Int32 {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        unsafe {
            var result = Int32(0)
            JSRuntime.check(OH_JSVM_GetValueInt32(context_.env, value_, inout result))
            return result
        }
    }

    public func toNumberUint32(): UInt32 {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        unsafe {
            var result = UInt32(0)
            JSRuntime.check(OH_JSVM_GetValueUint32(context_.env, value_, inout result))
            return result
        }
    }

    public func toNumberInt64(): Int64 {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        unsafe {
            var result = 0
            JSRuntime.check(OH_JSVM_GetValueInt64(context_.env, value_, inout result))
            return result
        }
    }

    public func toNumberFloat64(): Float64 {
        if (!isNumber()) {
            throw Exception("require number type but get ${typeof().toString()}")
        }
        unsafe {
            var result = 0.0
            JSRuntime.check(OH_JSVM_GetValueDouble(context_.env, value_, inout result))
            return result
        }
    }

    // TODO: misleading name, `toString` should convert anything to `String`.
    public func toString(): String {
        if (!isString()) {
            throw Exception("require string type but get ${typeof().toString()}")
        }
        return JSString(context_, this).toString()
    }

    public func toJSValue(_: JSContext): JSValue {
        return this
    }

    public static func fromJSValue(_: JSContext, value: JSValue): JSValue {
        return value
    }

    public static func isCurrentType(_: JSContext, value: JSValue): Bool {
        return true
    }
}
