/**
 * Created on 2025/3/5
 */
package ohos_app_cangjie_entry.js_interop

import ohos.file_fs.*
import std.collection.ArrayList

public struct JSCodeCache {
    public let data: CPointer<UInt8>
    public let length: UIntNative

    public init() {
        data = CPointer<UInt8>()
        length = 0
    }

    public init(data_: CPointer<UInt8>, length_: UIntNative) {
        data = data_
        length = length_
    }
}

public class JSScript {
    JSScript(
        let context: JSContext,
        let script_: JSVM_Script
    ) {}

    ~init() {
        context.postJSTask {
            unsafe { OH_JSVM_ReleaseScript(context.env, script_) }
        }
    }

    public func createCodeCache(): JSCodeCache {
        var result = CPointer<UInt8>()
        var length = UIntNative(0)
        unsafe {
            JSRuntime.check(OH_JSVM_CreateCodeCache(context.env, script_, inout result, inout length))
        }
        return JSCodeCache(result, length)
    }
}

public class JSScriptBuilder {
    private let options_ = ArrayList<JSVM_CompileOptions>()
    private var cache_ = ArrayList<CPointer<Unit>>()
    private var content_: String
    private let context_: JSContext
    private var hasOrigin_ = false

    public init(context: JSContext, src: String) {
        context_ = context
        content_ = src
    }

    ~init() {
        for (pointer in cache_) {
            unsafe { LibC.free(pointer) }
        }
    }

    public func setCompileMode(mode: JSVM_CompileMode): This {
        options_.add(JSVM_CompileOptions(JSVM_CompileOptionId.MODE, IntNative(mode.value)))
        return this
    }

    public func setNoneCache(): This {
        return setCompileCache(CPointer<UInt8>(), 0)
    }

    public func setCompileCache(buffer: CPointer<UInt8>, size: Int64): This {
        let pointer = LibC.malloc<JSVM_CodeCache>()
        let cache = JSVM_CodeCache(buffer, size)
        unsafe { pointer.write(cache) }
        cache_.add(CPointer<Unit>(pointer))
        options_.add(JSVM_CompileOptions(JSVM_CompileOptionId.CODE_CACHE, IntNative(pointer.toUIntNative())))
        return this
    }

    public func setEnableSourceMap(value: Bool): This {
        let iValue: IntNative = if (value) {1} else {0}
        options_.add(JSVM_CompileOptions(JSVM_CompileOptionId.ENABLE_SOURCE_MAP, iValue))
        return this
    }

    public func setOrigin(source: String, mapSrc: String, lineOffset!: Int64 = 0, columnOffset!: Int64 = 0): This {
        hasOrigin_ = true
        unsafe {
            let cSource = LibC.mallocCString(source)
            let cMapSrc = LibC.mallocCString(mapSrc)
            let origin = JSVM_ScriptOrigin(cSource, cMapSrc, lineOffset, columnOffset)
            let pointer = LibC.malloc<JSVM_ScriptOrigin>()
            pointer.write(origin)
            cache_.add(CPointer<Unit>(cSource.getChars()))
            cache_.add(CPointer<Unit>(cMapSrc.getChars()))
            cache_.add(CPointer<Unit>(pointer))
            options_.add(JSVM_CompileOptions(JSVM_CompileOptionId.SCRIPT_ORIGIN, IntNative(pointer.toUIntNative())))
        }
        return this
    }

    public func build(): JSScript {
        getOptions { size, options =>
            var script = JSVM_Script()
            let value = context_.string(content_).toJSValue()
            unsafe {
                JSRuntime.checkAndHandleError(context_, OH_JSVM_CompileScriptWithOptions(
                        context_.env, value.value_, size, options, inout script))
            }
            JSScript(context_, script)
        }
    }

    func getOptions<T>(callback: (Int64, CPointer<JSVM_CompileOptions>) -> T): T {
        unsafe {
            let rawArr = options_.getRawArray()
            let handle = acquireArrayRawData(rawArr)
            let result = callback(options_.size, handle.pointer)
            releaseArrayRawData(handle)
            clear()
            return result
        }
    }

    public func clear(): Unit {
        doRelease()
        options_.clear()
        cache_.clear()
    }

    private func doRelease(): Unit {
        for (pointer in cache_) {
            unsafe {
                LibC.free(pointer)
            }
        }
    }
}
