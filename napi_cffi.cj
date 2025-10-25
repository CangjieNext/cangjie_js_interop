/**
 * Created on 2025/3/6
 */
package ohos_app_cangjie_entry.js_interop

@C struct JSVM_VM__ {}
type JSVM_VM = CPointer<JSVM_VM__>
@C struct JSVM_VMScope__ {}
type JSVM_VMScope = CPointer<JSVM_VMScope__>
@C struct JSVM_EnvScope__ {}
type JSVM_EnvScope = CPointer<JSVM_EnvScope__>
@C struct JSVM_Script__ {}
type JSVM_Script = CPointer<JSVM_Script__>
@C struct JSVM_Env__ {}
type JSVM_Env = CPointer<JSVM_Env__>
@C struct JSVM_CpuProfiler__ {}
type JSVM_CpuProfiler = CPointer<JSVM_CpuProfiler__>
@C struct JSVM_Value__ {}
type JSVM_Value = CPointer<JSVM_Value__>
@C struct JSVM_Ref__ {}
type JSVM_Ref = CPointer<JSVM_Ref__>
@C struct JSVM_HandleScope__ {}
type JSVM_HandleScope = CPointer<JSVM_HandleScope__>
@C struct JSVM_EscapableHandleScope__ {}
type JSVM_EscapableHandleScope = CPointer<JSVM_EscapableHandleScope__>
@C struct JSVM_CallbackInfo__ {}
type JSVM_CallbackInfo = CPointer<JSVM_CallbackInfo__>
@C struct JSVM_Deferred__ {}
type JSVM_Deferred = CPointer<JSVM_Deferred__>

@C
struct JSVM_Callback {
    JSVM_Callback(
        let callback: CFunc<(JSVM_Env, JSVM_CallbackInfo) -> JSVM_Value>,
        let data: Int64
    ) {}
}

type JSVM_Finalize = CFunc<(JSVM_Env, CPointer<Unit>, Int64) -> Unit>

type JSVM_OutputStream = CFunc<(CString, Int32, CPointer<Unit>) -> Bool>

@C
struct JSVM_PropertyAttributes {
    JSVM_PropertyAttributes(let value: UInt32) {}

    init() {
        this(0)
    }

    public static let DEFAULT = JSVM_PropertyAttributes(0)
    public static let WRITABLE = JSVM_PropertyAttributes(1 << 0)
    public static let ENUMERABLE = JSVM_PropertyAttributes(1 << 1)
    public static let CONFIGURABLE = JSVM_PropertyAttributes(1 << 2)
    public static let NO_RECEIVER_CHECK = JSVM_PropertyAttributes(1 << 3)
    public static let STATIC = JSVM_PropertyAttributes(1 << 10)
    public static let DEFAULT_METHOD = WRITABLE | CONFIGURABLE
    public static let METHOD_NO_RECEIVER_CHECK = DEFAULT_METHOD | NO_RECEIVER_CHECK
    public static let DEFAULT_JSPROPERTY = WRITABLE | ENUMERABLE | CONFIGURABLE
    public static let JSPROPERTY_NO_RECEIVER_CHECK = DEFAULT_JSPROPERTY | NO_RECEIVER_CHECK

    public operator func |(target: JSVM_PropertyAttributes): JSVM_PropertyAttributes {
        return JSVM_PropertyAttributes(value | target.value)
    }

    public func cover(target: JSVM_PropertyAttributes): Bool {
        return (value & target.value) == target.value
    }
}

let JSVM_ValueTypeNames = [
    "undefined", "null", "boolean", "number", "string", "symbol", "object", "function", "external", "bigint"]

@C
public struct JSVM_ValueType {
    JSVM_ValueType(let value: UInt32) {}

    init() {
        this(0)
    }

    public static let UNDEFINED = JSVM_ValueType(0)
    public static let NULL = JSVM_ValueType(1)
    public static let BOOLEAN = JSVM_ValueType(2)
    public static let NUMBER = JSVM_ValueType(3)
    public static let STRING = JSVM_ValueType(4)
    public static let SYMBOL = JSVM_ValueType(5)
    public static let OBJECT = JSVM_ValueType(6)
    public static let FUNCTION = JSVM_ValueType(7)
    public static let EXTERNAL = JSVM_ValueType(8)
    public static let BIGINT = JSVM_ValueType(9)

    public operator func ==(target: JSVM_ValueType): Bool {
        return value == target.value
    }

    public operator func !=(target: JSVM_ValueType): Bool {
        return value != target.value
    }

    public func toString(): String {
        return JSVM_ValueTypeNames[Int64(value)]
    }
}

let JSVM_TypedarrayTypeNames = [
    "Int8Array", "Uint8Array", "Uint8ClampedArray", "Int16Array", "Uint16Array", "Int32Array", "Uint32Array",
    "Float32Array", "Float64Array", "Bigint64Array", "BigUint64Array"
]

@C
struct JSVM_TypedarrayType {
    JSVM_TypedarrayType(let value: UInt32) {}

    init() {
        this(0)
    }

    public static let INT8_ARRAY = JSVM_TypedarrayType(0)
    public static let UINT8_ARRAY = JSVM_TypedarrayType(1)
    public static let UINT8_CLAMPED_ARRAY = JSVM_TypedarrayType(2)
    public static let INT16_ARRAY = JSVM_TypedarrayType(3)
    public static let UINT16_ARRAY = JSVM_TypedarrayType(4)
    public static let INT32_ARRAY = JSVM_TypedarrayType(5)
    public static let UINT32_ARRAY = JSVM_TypedarrayType(6)
    public static let FLOAT32_ARRAY = JSVM_TypedarrayType(7)
    public static let FLOAT64_ARRAY = JSVM_TypedarrayType(8)
    public static let BIGINT64_ARRAY = JSVM_TypedarrayType(9)
    public static let BIGUINT64_ARRAY = JSVM_TypedarrayType(10)

    public func toString(): String {
        return JSVM_TypedarrayTypeNames[Int64(value)]
    }
}

let JSVM_StatusNames = [
    "JSVM_OK", "JSVM_INVALID_ARG", "JSVM_OBJECT_EXPECTED", "JSVM_STRING_EXPECTED", "JSVM_NAME_EXPECTED", "JSVM_FUNCTION_EXPECTED",
    "JSVM_NUMBER_EXPECTED", "JSVM_BOOLEAN_EXPECTED", "JSVM_ARRAY_EXPECTED", "JSVM_GENERIC_FAILURE", "JSVM_PENDING_EXCEPTION",
    "JSVM_CANCELLED", "JSVM_ESCAPE_CALLED_TWICE", "JSVM_HANDLE_SCOPE_MISMATCH", "JSVM_CALLBACK_SCOPE_MISMATCH", "JSVM_QUEUE_FULL",
    "JSVM_CLOSING", "JSVM_BIGINT_EXPECTED", "JSVM_DATE_EXPECTED", "JSVM_ARRAYBUFFER_EXPECTED", "JSVM_DETACHABLE_ARRAYBUFFER_EXPECTED",
    "JSVM_WOULD_DEADLOCK", "JSVM_NO_EXTERNAL_BUFFERS_ALLOWED", "JSVM_CANNOT_RUN_JS", "JSVM_INVALID_TYPE"
    ]

@C
struct JSVM_Status {
    JSVM_Status(let value: UInt64) {}

    init() {
        this(0)
    }

    public static let OK = JSVM_Status(0)
    public static let INVALID_ARG = JSVM_Status(1)
    public static let OBJECT_EXPECTED = JSVM_Status(2)
    public static let STRING_EXPECTED = JSVM_Status(3)
    public static let NAME_EXPECTED = JSVM_Status(4)
    public static let FUNCTION_EXPECTED = JSVM_Status(5)
    public static let NUMBER_EXPECTED = JSVM_Status(6)
    public static let BOOLEAN_EXPECTED = JSVM_Status(7)
    public static let ARRAY_EXPECTED = JSVM_Status(8)
    public static let GENERIC_FAILURE = JSVM_Status(9)
    public static let PENDING_EXCEPTION = JSVM_Status(10)
    public static let CANCELLED = JSVM_Status(11)
    public static let ESCAPE_CALLED_TWICE = JSVM_Status(12)
    public static let HANDLE_SCOPE_MISMATCH = JSVM_Status(13)
    public static let CALLBACK_SCOPE_MISMATCH = JSVM_Status(14)
    public static let QUEUE_FULL = JSVM_Status(15)
    public static let CLOSING = JSVM_Status(16)
    public static let BIGINT_EXPECTED = JSVM_Status(17)
    public static let DATE_EXPECTED = JSVM_Status(18)
    public static let ARRAYBUFFER_EXPECTED = JSVM_Status(19)
    public static let DETACHABLE_ARRAYBUFFER_EXPECTED = JSVM_Status(20)
    public static let WOULD_DEADLOCK = JSVM_Status(21)
    public static let NO_EXTERNAL_BUFFERS_ALLOWED = JSVM_Status(22)
    public static let CANNOT_RUN_JS = JSVM_Status(23)
    public static let INVALID_TYPE = JSVM_Status(24)

    public func toString(): String {
        return "[JSVM_Status: ${value}]: ${JSVM_StatusNames[Int64(value)]}"
    }

    public operator func ==(target: JSVM_Status): Bool {
        return value == target.value
    }

    public operator func !=(target: JSVM_Status): Bool {
        return value != target.value
    }

    public func isOk(): Bool {
        return value == OK.value
    }
}

@C
struct JSVM_KeyCollectionMode {
    JSVM_KeyCollectionMode(let value: UInt32) {}

    init() {
        this(0)
    }

    public static let JSVM_KEY_INCLUDE_PROTOTYPES = JSVM_KeyCollectionMode(0)
    public static let JSVM_KEY_OWN_ONLY = JSVM_KeyCollectionMode(1)
}

@C
struct JSVM_KeyFilter {
    JSVM_KeyFilter(let value: UInt32) {}

    init() {
        this(0)
    }

    public static let ALL_PROPERTIES = JSVM_KeyFilter(0)
    public static let WRITABLE = JSVM_KeyFilter(1)
    public static let ENUMERABLE = JSVM_KeyFilter(1 << 1)
    public static let CONFIGURABLE = JSVM_KeyFilter(1 << 2)
    public static let SKIP_STRINGS = JSVM_KeyFilter(1 << 3)
    public static let SKIP_SYMBOLS = JSVM_KeyFilter(1 << 4)

    public func cover(target: JSVM_KeyFilter): Bool {
        return (value & target.value) == target.value
    }
}

@C
struct JSVM_KeyConversion {
    JSVM_KeyConversion(let value: UInt32) {}

    init() {
        this(0)
    }

    public static let JSVM_KEY_KEEP_NUMBERS = JSVM_KeyConversion(0)
    public static let JSVM_KEY_NUMBERS_TO_STRINGS = JSVM_KeyConversion(1)
}

@C
struct JSVM_MemoryPressureLevel {
    JSVM_MemoryPressureLevel(let value: UInt32) {}

    init() {
        this(0)
    }

    public static let NONE = JSVM_MemoryPressureLevel(0)
    public static let MODERATE = JSVM_MemoryPressureLevel(1)
    public static let CRITICAL = JSVM_MemoryPressureLevel(2)
}

@C
public struct JSVM_CompileMode {
    JSVM_CompileMode(let value: UInt32) {}

    public static let DEFAULT = JSVM_CompileMode(0)
    public static let CONSUME_CODE_CACHE = JSVM_CompileMode(1)
    public static let EAGER_COMPILE = JSVM_CompileMode(2)
    public static let PRODUCE_COMPILE_PROFILE = JSVM_CompileMode(3)
    public static let CONSUME_COMPILE_PROFILE = JSVM_CompileMode(4)
}

@C
public struct JSVM_HeapStatistics {
    JSVM_HeapStatistics(
        public var totalHeapSize: UIntNative,
        public var totalHeapSizeExecutable: UIntNative,
        public var totalPhysicalSize: UIntNative,
        public var totalAvailableSize: UIntNative,
        public var usedHeapSize: UIntNative,
        public var heapSizeLimit: UIntNative,
        public var mallocedMemory: UIntNative,
        public var externalMemory: UIntNative,
        public var peakMallocedMemory: UIntNative,
        public var numberOfNativeContexts: UIntNative,
        public var numberOfDetachedContexts: UIntNative,
        public var totalGlobalHandlesSize: UIntNative,
        public var usedGlobalHandlesSize: UIntNative
    ) {}

    public init() {
        this(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }

    public func toString(): String {
        return "JSHeapStatistics{" +
               "totalHeapSize=" + totalHeapSize.toString() +
               ", totalHeapSizeExecutable=" + totalHeapSizeExecutable.toString() +
               ", totalPhysicalSize=" + totalPhysicalSize.toString() +
               ", totalAvailableSize=" + totalAvailableSize.toString() +
               ", usedHeapSize=" + usedHeapSize.toString() +
               ", heapSizeLimit=" + heapSizeLimit.toString() +
               ", mallocedMemory=" + mallocedMemory.toString() +
               ", externalMemory=" + externalMemory.toString() +
               ", peakMallocedMemory=" + peakMallocedMemory.toString() +
               ", numberOfNativeContexts=" + numberOfNativeContexts.toString() +
               ", numberOfDetachedContexts=" + numberOfDetachedContexts.toString() +
               ", totalGlobalHandlesSize=" + totalGlobalHandlesSize.toString() +
               ", usedGlobalHandlesSize=" + usedGlobalHandlesSize.toString() +
               '}'
    }
}

@C
struct JSVM_InitOptions {
    JSVM_InitOptions(
        let externalReferences: CPointer<IntNative>,
        let argc: CPointer<Int32>,
        let argv: CPointer<CString>,
        let removeFlags: Bool
    ) {}

    init() {
        this(CPointer<IntNative>(), CPointer<Int32>(), CPointer<CString>(), false)
    }
}

@C
struct JSVM_CreateVMOptions {
    JSVM_CreateVMOptions(
        let maxOldGenerationSize: Int64,
        let maxYoungGenerationSize: Int64,
        let initialOldGenerationSize: Int64,
        let initialYoungGenerationSize: Int64,
        let snapshotBlobData: CString,
        let snapshotBlobSize: Int64,
        let isForSnapshotting: Bool
    ) {}

    init() {
        this(0, 0, 0, 0, CString(CPointer<UInt8>()), 0, false)
    }
}

@C
struct JSVM_VMInfo {
    JSVM_VMInfo(
        let apiVersion: UInt32,
        let engine: CString,
        let version: CString,
        let cachedDataVersionTag: UInt32
    ) {}
}

@C
struct JSVM_PropertyDescriptor {
    JSVM_PropertyDescriptor(
        let utf8name: CString,
        let name: JSVM_Value,
        let method: JSVM_Callback,
        let getter: JSVM_Callback,
        let setter: JSVM_Callback,
        let value: JSVM_Value,
        let attribute: JSVM_PropertyAttributes
    ) {}
}

@C
struct JSVM_ExtendedErrorInfo {
    JSVM_ExtendedErrorInfo(
        let errorMessage: CString,
        let engineReserved: CPointer<Unit>,
        let engineErrorCode: UInt32,
        let errorCode: JSVM_Status
    ) {}
}

@C
struct JSVM_TypeTag {
    JSVM_TypeTag(
        let lower: UInt64,
        let upper: UInt64
    ) {}
}

@C
struct JSVM_PropertyHandlerConfigurationStruct {
    JSVM_PropertyHandlerConfigurationStruct(
        let genericNamedPropertyGetterCallback: CFunc<(JSVM_Env, JSVM_Value, JSVM_Value, JSVM_Value) -> JSVM_Value>,
        let genericNamedPropertySetterCallback: CFunc<(JSVM_Env, JSVM_Value, JSVM_Value, JSVM_Value, JSVM_Value) -> JSVM_Value>,
        let genericNamedPropertyDeleterCallback: CFunc<(JSVM_Env, JSVM_Value, JSVM_Value, JSVM_Value) -> JSVM_Value>,
        let genericNamedPropertyEnumeratorCallback: CFunc<(JSVM_Env, JSVM_Value, JSVM_Value) -> JSVM_Value>,
        let genericIndexedPropertyGetterCallback: CFunc<(JSVM_Env, JSVM_Value, JSVM_Value, JSVM_Value) -> JSVM_Value>,
        let genericIndexedPropertySetterCallback: CFunc<(JSVM_Env, JSVM_Value, JSVM_Value, JSVM_Value, JSVM_Value) -> JSVM_Value>,
        let genericIndexedPropertyDeleterCallback: CFunc<(JSVM_Env, JSVM_Value, JSVM_Value, JSVM_Value) -> JSVM_Value>,
        let genericIndexedPropertyEnumeratorCallback: CFunc<(JSVM_Env, JSVM_Value, JSVM_Value) -> JSVM_Value>,
        let namedPropertyData: JSVM_Value,
        let indexedPropertyData: JSVM_Value
    ) {}
}

type JSVM_PropertyHandlerCfg = CPointer<JSVM_PropertyHandlerConfigurationStruct>

@C
struct JSVM_ScriptOrigin {
    JSVM_ScriptOrigin(
        let sourceMapUrl: CString,
        let resourceName: CString,
        let resourceLineOffset: Int64,
        let resourceColumnOffset: Int64
    ) {}
}

@C
struct JSVM_CompileOptionId {
    JSVM_CompileOptionId(let value: UInt32) {}

    public static let MODE = JSVM_CompileOptionId(0)
    public static let CODE_CACHE = JSVM_CompileOptionId(1)
    public static let SCRIPT_ORIGIN = JSVM_CompileOptionId(2)
    public static let COMPILE_PROFILE = JSVM_CompileOptionId(3)
    public static let ENABLE_SOURCE_MAP = JSVM_CompileOptionId(4)
}

@C
struct JSVM_CompileOptions {
    JSVM_CompileOptions(
        let id: JSVM_CompileOptionId,
        let value: IntNative
    ) {}
}

@C
struct JSVM_CodeCache {
    JSVM_CodeCache(
        var cache: CPointer<UInt8>,
        var length: Int64
    ) {}

    init() {
        this(CPointer<UInt8>(), 0)
    }
}

@C
struct JSVM_PromiseRejectEvent {
    JSVM_PromiseRejectEvent(let value: UInt32) {}

    public static let JREJECT_OTHER_REASONS = JSVM_PromiseRejectEvent(0)
    public static let JREJECT_WITH_NO_HANDLER = JSVM_PromiseRejectEvent(1)
    public static let JADD_HANDLER_AFTER_REJECTED = JSVM_PromiseRejectEvent(2)
    public static let JREJECT_AFTER_RESOLVED = JSVM_PromiseRejectEvent(3)
    public static let JRESOLVE_AFTER_RESOLVED = JSVM_PromiseRejectEvent(4)
}

@C
struct JSVM_MessageErrorLevel {
    JSVM_MessageErrorLevel(let value: UInt32) {}

    public static let JSVM_MESSAGE_LOG = JSVM_MessageErrorLevel(1 << 0)
    public static let JSVM_MESSAGE_DEBUG = JSVM_MessageErrorLevel(1 << 1)
    public static let JSVM_MESSAGE_INFO = JSVM_MessageErrorLevel(1 << 2)
    public static let JSVM_MESSAGE_ERROR = JSVM_MessageErrorLevel(1 << 3)
    public static let JSVM_MESSAGE_WARNING = JSVM_MessageErrorLevel(1 << 4)
    public static let JSVM_MESSAGE_ALL = JSVM_MessageErrorLevel(0b11111)
}

type JSVM_HandlerForOOMError = CFunc<(CString, CString, Bool) -> Unit>
type JSVM_HandlerForFatalError = CFunc<(CString, CString) -> Unit>
type JSVM_HandlerForPromiseReject = CFunc<(JSVM_Env, JSVM_PromiseRejectEvent, JSVM_Value) -> Unit>

@C
struct JSVM_DefineClassOptionsId {
    JSVM_DefineClassOptionsId(let value: UInt32) {}

    public static let NORMAL = JSVM_DefineClassOptionsId(0)
    public static let WITH_COUNT = JSVM_DefineClassOptionsId(1)
    public static let WITH_PROPERTY_HANDLER = JSVM_DefineClassOptionsId(2)
}

@C
struct JSVM_DefineClassOptions {
    JSVM_DefineClassOptions(
        let id: JSVM_DefineClassOptionsId,
        let content: IntNative
    ) {}
}

@C
struct JSVM_PropertyHandler {
    JSVM_PropertyHandler(
        let propertyHandlerCfg: JSVM_PropertyHandlerCfg,
        let callAsFunctionCallback: JSVM_Callback
    ) {}
}

@C
struct JSVM_GCType {
    JSVM_GCType(let value: UInt32) {}

    public static let JSVM_GC_TYPE_SCAVENGE = JSVM_GCType(1 << 0)
    public static let JSVM_GC_TYPE_MINOR_MARK_COMPACT = JSVM_GCType(1 << 1)
    public static let JSVM_GC_TYPE_MARK_SWEEP_COMPACT = JSVM_GCType(1 << 2)
    public static let JSVM_GC_TYPE_INCREMENTAL_MARKING = JSVM_GCType(1 << 3)
    public static let JSVM_GC_TYPE_PROCESS_WEAK_CALLBACKS = JSVM_GCType(1 << 4)
    public static let JSVM_GC_TYPE_ALL = JSVM_GCType(0b11111)
}

@C
struct JSVM_GCCallbackFlags {
    JSVM_GCCallbackFlags(let value: UInt32) {}

    public static let JSVM_NO_GC_CALLBACK_FLAGS = JSVM_GCCallbackFlags(0)
    public static let JSVM_GC_CALLBACK_CONSTRUCT_RETAINED_OBJECT_INFOS = JSVM_GCCallbackFlags(1)
    public static let JSVM_GC_CALLBACK_FORCED = JSVM_GCCallbackFlags(2)
    public static let JSVM_GC_CALLBACK_SYNCHRONOUS_PHANTOM_CALLBACK_PROCESSING = JSVM_GCCallbackFlags(3)
    public static let JSVM_GC_CALLBACK_COLLECT_ALL_AVAILABLE_GARBAGE = JSVM_GCCallbackFlags(4)
    public static let JSVM_GC_CALLBACK_COLLECT_ALL_EXTERNAL_MEMORY = JSVM_GCCallbackFlags(5)
    public static let JSVM_GC_CALLBACK_SCHEDULE_IDLE_GARBAGE_COLLECTION = JSVM_GCCallbackFlags(6)
}

type JSVM_HandlerForGC = CFunc<(JSVM_VM, JSVM_GCType, JSVM_GCCallbackFlags, CPointer<Unit>) -> Unit>

foreign {
    // TODO: check all the int types.
    // Create VM and context.
    func OH_JSVM_Init(options: CPointer<JSVM_InitOptions>): JSVM_Status
    func OH_JSVM_CreateVM(options: CPointer<JSVM_CreateVMOptions>, result: CPointer<JSVM_VM>): JSVM_Status
    func OH_JSVM_DestroyVM(vm: JSVM_VM): JSVM_Status
    func OH_JSVM_OpenVMScope(vm: JSVM_VM, result: CPointer<JSVM_VMScope>): JSVM_Status
    func OH_JSVM_CloseVMScope(vm: JSVM_VM, scope: JSVM_VMScope): JSVM_Status
    func OH_JSVM_CreateEnv(vm: JSVM_VM, propertyCount: Int64, properties: CPointer<JSVM_PropertyDescriptor>, result: CPointer<JSVM_Env>): JSVM_Status
    func OH_JSVM_DestroyEnv(vm: JSVM_Env): JSVM_Status
    func OH_JSVM_OpenEnvScope(env: JSVM_Env, result: CPointer<JSVM_EnvScope>): JSVM_Status
    func OH_JSVM_CloseEnvScope(env: JSVM_Env, scope: JSVM_EnvScope): JSVM_Status
    func OH_JSVM_OpenHandleScope(env: JSVM_Env, result: CPointer<JSVM_HandleScope>): JSVM_Status
    func OH_JSVM_CloseHandleScope(env: JSVM_Env, scope: JSVM_HandleScope): JSVM_Status
    // Handle exceptions.
    func OH_JSVM_ThrowError(env: JSVM_Env, code: CString, msg: CString): JSVM_Status
    func OH_JSVM_GetAndClearLastException(env: JSVM_Env, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_IsExceptionPending(env: JSVM_Env, result: CPointer<Bool>): JSVM_Status
    // Manage object lifetime.
    func OH_JSVM_CreateReference(env: JSVM_Env, value: JSVM_Value, initialRefCount: UInt32, result: CPointer<JSVM_Ref>): JSVM_Status
    func OH_JSVM_DeleteReference(env: JSVM_Env, ref: JSVM_Ref): JSVM_Status
    func OH_JSVM_ReferenceRef(env: JSVM_Env, ref: JSVM_Ref, result: CPointer<UInt32>): JSVM_Status
    func OH_JSVM_ReferenceUnref(env: JSVM_Env, ref: JSVM_Ref, result: CPointer<UInt32>): JSVM_Status
    func OH_JSVM_GetReferenceValue(env: JSVM_Env, ref: JSVM_Ref, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_ReleaseScript(env: JSVM_Env, script: JSVM_Script): JSVM_Status
    // Create JS types.
    func OH_JSVM_CreateArray(env: JSVM_Env, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateArrayWithLength(env: JSVM_Env, length: Int64, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateArraybuffer(env: JSVM_Env, byteLength: Int64, data: CPointer<CPointer<Unit>>, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateObject(env: JSVM_Env, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateInt32(env: JSVM_Env, value: Int32, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateUint32(env: JSVM_Env, value: UInt32, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateInt64(env: JSVM_Env, value: Int64, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateDouble(env: JSVM_Env, value: Float64, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateStringUtf8(env: JSVM_Env, str: CString, length: Int64, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateMap(env: JSVM_Env, result: CPointer<JSVM_Value>): JSVM_Status
    // Compile and run JS code.
    func OH_JSVM_CompileScript(env: JSVM_Env, script: JSVM_Value, data: CPointer<UInt8>, cacheDataLength: UIntNative, eagerCompile: Bool, cacheRejected: CPointer<Bool>, result: CPointer<JSVM_Script>): JSVM_Status
    func OH_JSVM_CompileScriptWithOptions(env: JSVM_Env, script: JSVM_Value, optionCount: Int64, options: CPointer<JSVM_CompileOptions>, result: CPointer<JSVM_Script>): JSVM_Status
    func OH_JSVM_CreateCodeCache(env: JSVM_Env, script: JSVM_Script, data: CPointer<CPointer<UInt8>>, length: CPointer<UIntNative>): JSVM_Status
    func OH_JSVM_RunScript(env: JSVM_Env, script: JSVM_Script, result: CPointer<JSVM_Value>): JSVM_Status
    // Get C types/information directly or from JS types.
    func OH_JSVM_GetArrayLength(env: JSVM_Env, value: JSVM_Value, result: CPointer<UInt32>): JSVM_Status
    func OH_JSVM_GetValueBool(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_GetValueInt32(env: JSVM_Env, value: JSVM_Value, result: CPointer<Int32>): JSVM_Status
    func OH_JSVM_GetValueUint32(env: JSVM_Env, value: JSVM_Value, result: CPointer<UInt32>): JSVM_Status
    func OH_JSVM_GetValueInt64(env: JSVM_Env, value: JSVM_Value, result: CPointer<Int64>): JSVM_Status
    func OH_JSVM_GetValueDouble(env: JSVM_Env, value: JSVM_Value, result: CPointer<Float64>): JSVM_Status
    func OH_JSVM_GetValueBigintWords(env: JSVM_Env, value: JSVM_Value, signBit: CPointer<Int>, wordCount: CPointer<UIntNative>, result: CPointer<UInt64>): JSVM_Status
    func OH_JSVM_GetValueStringUtf8(env: JSVM_Env, value: JSVM_Value, buf: CPointer<UInt8>, bufSize: Int64, result: CPointer<Int64>): JSVM_Status
    func OH_JSVM_GetBoolean(env: JSVM_Env, value: Bool, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_GetGlobal(env: JSVM_Env, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_GetNull(env: JSVM_Env, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_GetUndefined(env: JSVM_Env, result: CPointer<JSVM_Value>): JSVM_Status
    // Check types.
    func OH_JSVM_Typeof(env: JSVM_Env, value: JSVM_Value, result: CPointer<JSVM_ValueType>): JSVM_Status
    func OH_JSVM_Instanceof(env: JSVM_Env, object: JSVM_Value, constructor: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsArray(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsArraybuffer(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsDate(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsTypedarray(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsDataview(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsCallable(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsUndefined(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsNull(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsNullOrUndefined(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsBoolean(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsNumber(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsString(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsSymbol(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsFunction(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsObject(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsBigInt(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_IsMap(env: JSVM_Env, value: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_StrictEquals(env: JSVM_Env, lhs: JSVM_Value, rhs: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_Equals(env: JSVM_Env, lhs: JSVM_Value, rhs: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    // Operations of JS properties.
    func OH_JSVM_GetPropertyNames(env: JSVM_Env, object: JSVM_Value, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_GetAllPropertyNames(env: JSVM_Env, object: JSVM_Value, keyMode: JSVM_KeyCollectionMode, keyFilter: JSVM_KeyFilter, keyConversion: JSVM_KeyConversion, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_SetProperty(env: JSVM_Env, object: JSVM_Value, key: JSVM_Value, value: JSVM_Value): JSVM_Status
    func OH_JSVM_GetProperty(env: JSVM_Env, object: JSVM_Value, key: JSVM_Value, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_HasProperty(env: JSVM_Env, object: JSVM_Value, key: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_DeleteProperty(env: JSVM_Env, object: JSVM_Value, key: JSVM_Value, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_GetNamedProperty(env: JSVM_Env, object: JSVM_Value, name: CString, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_SetElement(env: JSVM_Env, object: JSVM_Value, index: UInt32, value: JSVM_Value): JSVM_Status
    func OH_JSVM_GetElement(env: JSVM_Env, object: JSVM_Value, index: UInt32, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_HasElement(env: JSVM_Env, object: JSVM_Value, index: UInt32, result: CPointer<Bool>): JSVM_Status
    func OH_JSVM_DeleteElement(env: JSVM_Env, object: JSVM_Value, index: UInt32, result: CPointer<Bool>): JSVM_Status
    // Operations of JS functions.
    func OH_JSVM_CallFunction(env: JSVM_Env, thisArg: JSVM_Value, fun: JSVM_Value, argc: Int64, argv: CPointer<JSVM_Value>, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_CreateFunction(env: JSVM_Env, name: CPointer<UInt8>, nameLen: Int64, callback: CPointer<JSVM_Callback>, result: CPointer<JSVM_Value>): JSVM_Status
    func OH_JSVM_GetCbInfo(env: JSVM_Env, cbInfo: JSVM_CallbackInfo, argc: CPointer<Int64>, argv: CPointer<JSVM_Value>, thisArg: CPointer<JSVM_Value>, hint: CPointer<Int64>): JSVM_Status
    func OH_JSVM_GetNewTarget(env: JSVM_Env, cbInfo: JSVM_CallbackInfo, result: CPointer<JSVM_Value>): JSVM_Status
    // Wrap objects.
    func OH_JSVM_AddFinalizer(env: JSVM_Env, object: JSVM_Value, data: CPointer<Unit>, callback: JSVM_Finalize, hint: Int64, result: CPointer<JSVM_Ref>): JSVM_Status
    // Manage memory.
    func OH_JSVM_MemoryPressureNotification(env: JSVM_Env, level: JSVM_MemoryPressureLevel): JSVM_Status
    func OH_JSVM_GetHeapStatistics(vm: JSVM_VM, result: CPointer<JSVM_HeapStatistics>): JSVM_Status
}
