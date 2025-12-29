# 仓颉与 JavaScript 互操作库 API 文档

仓颉与 JavaScript 互操作库提供了仓颉语言与 JavaScript 语言的互操作能力。

## interface FromJSValue

```cangjie
public interface FromJSValue<T> {
    static func fromJSValue(src: JSValue): T
    static func isCurrentType(src: JSValue): Bool
}
```

**功能：** 作为所有可由 JSValue 转换而来的类型的父类，提供 fromJSValue 和 fromJSValue 方法。

### func fromJSValue(JSContext, JSValue)

```cangjie
static func fromJSValue(context: JSContext, src: JSValue): T
```

**功能：** 将 JSValue 转换为仓颉类型。

**参数：**

| 参数名  | 类型                          | 必填 | 默认值 | 说明                      |
| :------ | :---------------------------- | :--- | :----- | :------------------------ |
| context | [JSContext](#class-jscontext) | 是   | -      | JavaScript 互操作上下文。 |
| src     | [JSValue](#class-JSValue)    | 是   | -      | JavaScript 统一类型。     |

**返回值：**

| 类型 | 说明     |
| :--- | :------- |
| T    | 仓颉类型 |

### func isCurrentType(JSContext, JSValue)

```cangjie
static func isCurrentType(context: JSContext, src: JSValue): Bool
```

**功能：** 判断 src 的实际类型是否是 T。

**参数：**

| 参数名  | 类型                          | 必填 | 默认值 | 说明                      |
| :------ | :---------------------------- | :--- | :----- | :------------------------ |
| context | [JSContext](#class-jscontext) | 是   | -      | JavaScript 互操作上下文。 |
| src     | [JSValue](#class-JSValue)    | 是   | -      | JavaScript 统一类型。     |

**返回值：**

| 类型 | 说明                     |
| :--- | :----------------------- |
| Bool | src 的实际类型是否是 T。 |

## interface JSKeyable

```cangjie
sealed interface JSKeyable <: ToString {}
```

**功能：** 作为 JSObject 的键。该接口为 String、Int64、[JSString](#class-jsstring) 类型实现了扩展方法。

**父类型：**

* ToString

## interface ToJSValue

```cangjie
public interface ToJSValue {
    func toJSValue(context: JSContext): JSValue
}
```

**功能：** 作为所有可转换为 JSValue 的类型的父类，提供 toJSValue 方法。

### func toJSValue(JSContext)

```cangjie
func toJSValue(context: JSContext): JSValue
```

**功能：** 将仓颉类型转换为 JSValue。

**参数：**

| 参数名  | 类型                          | 必填 | 默认值 | 说明                      |
| :------ | :---------------------------- | :--- | :----- | :------------------------ |
| context | [JSContext](#class-jscontext) | 是   | -      | JavaScript 互操作上下文。 |

**返回值：**

| 类型                       | 说明                  |
| :------------------------- | :-------------------- |
| [JSValue](#class-jsvalue) | JavaScript 统一类型。 |

## class JSArray

```cangjie
public class JSArray <: JSHeapObject & FromJSValue<JSArray> {}
```

**功能：** 对 JavaScript 数组进行跨语言强引用，用来获取数组长度、删除和读写数组元素。

**父类型：**

* [JSHeapObject](#class-jsheapobject)
* [FromJSValue](#interface-fromjsvalue)

### prop size

```cangjie
public prop size: Int64
```

**功能：** 获取数组长度。

**类型：** Int64

**可读写性：** 只读

### func deleteAt(Int64)

```cangjie
public func deleteAt(index: Int64): Bool
```

**功能：** 删除指定位置的元素。

**参数：**

| 参数名 | 类型  | 必填 | 默认值 | 说明               |
| :----- | :---- | :--- | :----- | :----------------- |
| index  | Int64 | 是   | -      | 待删除元素的位置。 |

**返回值：**

| 类型 | 说明           |
| :--- | :------------- |
| Bool | 是否删除成功。 |

### func \[](Int64)

```cangjie
public operator func[](index: Int64): JSValue
```

**功能：** 读取指定位置的元素。

**参数：**

| 参数名 | 类型  | 必填 | 默认值 | 说明               |
| :----- | :---- | :--- | :----- | :----------------- |
| index  | Int64 | 是   | -      | 待读取元素的位置。 |

**返回值：**

| 类型                       | 说明             |
| :------------------------- | :--------------- |
| [JSValue](#class-jsvalue) | 指定位置的元素。 |

### func \[](Int64, ToJSValue)

```cangjie
public operator func[](index: Int64, value!: ToJSValue): Unit
```

**功能：** 将指定元素写入指定位置。

**参数：**

| 参数名 | 类型                              | 必填 | 默认值 | 说明               |
| :----- | :-------------------------------- | :--- | :----- | :----------------- |
| index  | Int64                             | 是   | -      | 待写入元素的位置。 |
| value  | [ToJSValue](#interface-tojsvalue) | 是   | -      | 待写入的元素。     |

## class JSBoolean

```cangjie
public class JSBoolean {}
```

**功能：** 对 JavaScript 布尔对象进行弱引用，用来转换为仓颉布尔值。

### func toBool()

```cangjie
public func toBool(): Bool
```

**功能：** 将 JavaScript 布尔对象转换为仓颉布尔值。

**返回值：**

| 类型 | 说明                   |
| :--- | :--------------------- |
| Bool | 转换得到的仓颉布尔值。 |

## class JSContext

```cangjie
public class JSContext {}
```

**功能：** 对 JavaScript 上下文进行引用，用来创建 JSValue 和跨语言强引用、管理 JavaScript 侧引用的仓颉对象的生命周期。

### prop global

```cangjie
public prop global: JSObject
```

**功能：** 获取 JavaScript 全局对象。

**类型：** [JSObject](#class-jsobject)

**可读写性：** 只读

### func array()

```cangjie
public func array(): JSArray
```

**功能：** 创建空的 JavaScript 数组对象。

**返回值：**

| 类型                      | 说明                  |
| :------------------------ | :-------------------- |
| [JSArray](#class-jsarray) | JavaScript 数组引用。 |

### func array(Array\<ToJSValue>)

```cangjie
public func array(data: Array<ToJSValue>): JSArray
```

**功能：** 以给定数据创建 JavaScript 数组对象。

**参数：**

| 参数名 | 类型      | 必填 | 默认值 | 说明       |
| :----- | :-------- | :--- | :----- | :--------- |
| data   | Array<[ToJSValue](#interface-tojsvalue)> | 是   | -      | 仓颉数组。 |

**返回值：**

| 类型                      | 说明                  |
| :------------------------ | :-------------------- |
| [JSArray](#class-jsarray) | JavaScript 数组引用。 |

### func boolean(Bool)

```cangjie
public func boolean(value: Bool): JSBoolean
```

**功能：** 以给定数据创建 JavaScript 布尔对象。

**参数：**

| 参数名 | 类型 | 必填 | 默认值 | 说明         |
| :----- | :--- | :--- | :----- | :----------- |
| value  | Bool | 是   | -      | 仓颉布尔值。 |

**返回值：**

| 类型                           | 说明                  |
| :----------------------------- | :-------------------- |
| [JSBoolean](#class-jsboolean) | JavaScript 布尔引用。 |

### func createCodeCache(String)

```cangjie
public func createCodeCache(src: String): JSCodeCache
```

**功能：** 以给定数据创建 JavaScript 代码缓存。

**参数：**

| 参数名 | 类型   | 必填 | 默认值 | 说明                               |
| :----- | :----- | :--- | :----- | :--------------------------------- |
| src    | String | 是   | -      | 包含 JavaScript 源码的仓颉字符串。 |

**返回值：**

| 类型                               | 说明                  |
| :--------------------------------- | :-------------------- |
| [JSCodeCache](#struct-jscodecache) | JavaScript 代码缓存。 |

### func evaluate(String, JSCodeCache)

```cangjie
public func evaluate(src: String, cache!: JSCodeCache = JSCodeCache.emptyCache): JSValue
```

**功能：** 将给定的代码和代码缓存交由 JavaScript 运行时进行编译和运行。当代码和代码缓存校验一致时，将使用缓存来加速编译，否则直接编译代码。

**参数：**

| 参数名 | 类型                               | 必填 | 默认值                 | 说明                                         |
| :----- | :--------------------------------- | :--- | :--------------------- | :------------------------------------------- |
| src    | String                             | 是   | -                      | 包含 JavaScript 源码的仓颉字符串。           |
| cache  | [JSCodeCache](#struct-jscodecache) | 否   | JSCodeCache.emptyCache | 命名参数。在仓颉存储的 JavaScript 代码缓存。 |

**返回值：**

| 类型                       | 说明                 |
| :------------------------- | :------------------- |
| [JSValue](#class-jsvalue) | 代码运行的返回结果。 |

### func function(JSLambda)

```cangjie
public func function(lambda: JSLambda): JSFunction
```

**功能：** 以给定数据创建 JavaScript 函数对象。

**参数：**

| 参数名 | 类型                       | 必填 | 默认值 | 说明       |
| :----- | :------------------------- | :--- | :----- | :--------- |
| lambda | [JSLambda](#type-jslambda) | 是   | -      | 仓颉函数。 |

**返回值：**

| 类型                            | 说明                  |
| :------------------------------ | :-------------------- |
| [JSFunction](#class-jsfunction) | JavaScript 函数引用。 |

### func function(String, JSLambda)

```cangjie
public func function(name: String, lambda: JSLambda): JSFunction
```

**功能：** 以给定数据创建 JavaScript 函数对象。

**参数：**

| 参数名 | 类型                       | 必填 | 默认值 | 说明       |
| :----- | :------------------------- | :--- | :----- | :--------- |
| name   | String                     | 是   | -      | 函数名字。 |
| lambda | [JSLambda](#type-jslambda) | 是   | -      | 仓颉函数。 |

**返回值：**

| 类型                            | 说明                  |
| :------------------------------ | :-------------------- |
| [JSFunction](#class-jsfunction) | JavaScript 函数引用。 |

### func garbageCollect()

```cangjie
public func garbageCollect(): Unit
```

**功能：** 提醒 JavaScript 运行时进行垃圾回收。

### func map()

```cangjie
public func map(): JSMap
```

**功能：** 创建空的 JavaScript 映射对象。

**返回值：**

| 类型                  | 说明                  |
| :-------------------- | :-------------------- |
| [JSMap](#class-jsmap) | JavaScript 映射引用。 |

### func map(Array\<(ToJSValue, ToJSValue)>)

```cangjie
public func map(pairs: Array<(ToJSValue, ToJSValue)>): JSMap
```

**功能：** 以给定数据创建 JavaScript 映射对象。

**参数：**

| 参数名 | 类型          | 必填 | 默认值 | 说明                       |
| :----- | :------------ | :--- | :----- | :------------------------- |
| pairs  | Array<([ToJSValue](#interface-tojsvalue), [ToJSValue](#interface-tojsvalue))> | 是   | -      | 包含映射键值对的仓颉数组。 |

**返回值：**

| 类型                  | 说明                  |
| :-------------------- | :-------------------- |
| [JSMap](#class-jsmap) | JavaScript 映射引用。 |

### func newScope\<T>(() -> T)

```cangjie
public func newScope<T>(task: () -> T): T
```

**功能：** 创建一层 JavaScript 作用域来执行给定的互操作任务。所有对 JavaScript 数据的操作都必须在至少一层的作用域之内。

**参数：**

| 参数名 | 类型    | 必填 | 默认值 | 说明       |
| :----- | :------ | :--- | :----- | :--------- |
| task   | () -> T | 是   | -      | 仓颉数字。 |

**返回值：**

| 类型 | 说明                   |
| :--- | :--------------------- |
| T    | 互操作任务的返回结果。 |

### func null()

```cangjie
public func null(): JSNull
```

**功能：** 创建 JavaScript Null 对象。

**返回值：**

| 类型                     | 说明                   |
| :----------------------- | :--------------------- |
| [JSNull](#class-jsnull) | JavaScript Null 引用。 |

### func number(Float64)

```cangjie
public func number(value: Float64): JSNumber
```

**功能：** 以给定数据创建 JavaScript 数字对象。

**参数：**

| 参数名 | 类型    | 必填 | 默认值 | 说明       |
| :----- | :------ | :--- | :----- | :--------- |
| value  | Float64 | 是   | -      | 仓颉数字。 |

**返回值：**

| 类型                         | 说明                  |
| :--------------------------- | :-------------------- |
| [JSNumber](#class-jsnumber) | JavaScript 数字引用。 |

### func number(Int32)

```cangjie
public func number(value: Int32): JSNumber
```

**功能：** 以给定数据创建 JavaScript 数字对象。

**参数：**

| 参数名 | 类型  | 必填 | 默认值 | 说明       |
| :----- | :---- | :--- | :----- | :--------- |
| value  | Int32 | 是   | -      | 仓颉数字。 |

**返回值：**

| 类型                         | 说明                  |
| :--------------------------- | :-------------------- |
| [JSNumber](#class-jsnumber) | JavaScript 数字引用。 |

### func number(Int64)

```cangjie
public func number(value: Int64): JSNumber
```

**功能：** 以给定数据创建 JavaScript 数字对象。

**参数：**

| 参数名 | 类型  | 必填 | 默认值 | 说明       |
| :----- | :---- | :--- | :----- | :--------- |
| value  | Int64 | 是   | -      | 仓颉数字。 |

**返回值：**

| 类型                         | 说明                  |
| :--------------------------- | :-------------------- |
| [JSNumber](#class-jsnumber) | JavaScript 数字引用。 |

### func number(UInt32)

```cangjie
public func number(value: UInt32): JSNumber
```

**功能：** 以给定数据创建 JavaScript 数字对象。

**参数：**

| 参数名 | 类型   | 必填 | 默认值 | 说明       |
| :----- | :----- | :--- | :----- | :--------- |
| value  | UInt32 | 是   | -      | 仓颉数字。 |

**返回值：**

| 类型                         | 说明                  |
| :--------------------------- | :-------------------- |
| [JSNumber](#class-jsnumber) | JavaScript 数字引用。 |

### func object()

```cangjie
public func object(): JSObject
```

**功能：** 创建空的 JavaScript 对象。

**返回值：**

| 类型                        | 说明                  |
| :-------------------------- | :-------------------- |
| [JSObject](#class-jsobject) | JavaScript 对象引用。 |

### func object(Array<(JSKeyable, ToJSValue)>)

```cangjie
public func object(properties: Array<(JSKeyable, ToJSValue)>): JSObject
```

**功能：** 以给定数据创建 JavaScript 对象。

**参数：**

| 参数名     | 类型          | 必填 | 默认值 | 说明                       |
| :--------- | :------------ | :--- | :----- | :------------------------- |
| properties | Array<([JSKeyable](#interface-jskeyable), [ToJSValue](#interface-tojsvalue))> | 是   | -      | 包含属性键值对的仓颉数组。 |

**返回值：**

| 类型                        | 说明                  |
| :-------------------------- | :-------------------- |
| [JSObject](#class-jsobject) | JavaScript 对象引用。 |

### func string(String)

```cangjie
public func string(value: String): JSString
```

**功能：** 以给定数据创建 JavaScript 字符串对象。

**参数：**

| 参数名 | 类型   | 必填 | 默认值 | 说明         |
| :----- | :----- | :--- | :----- | :----------- |
| value  | String | 是   | -      | 仓颉字符串。 |

**返回值：**

| 类型                        | 说明                    |
| :-------------------------- | :---------------------- |
| [JSString](#class-jsstring) | JavaScript 字符串引用。 |

### func undefined()

```cangjie
public func undefined(): JSUndefined
```

**功能：** 创建 JavaScript Undefined 对象。

**返回值：**

| 类型                               | 说明                        |
| :--------------------------------- | :-------------------------- |
| [JSUndefined](#class-jsundefined) | JavaScript Undefined 引用。 |

## class JSFunction

```cangjie
public class JSFunction <: JSHeapObject & FromJSValue<JSFunction> {}
```

**功能：** 对 JavaScript 函数进行跨语言强引用，用来调用 JavaScript 函数。

**父类型：**

* [JSHeapObject](#class-jsheapobject)
* [FromJSValue](#interface-fromjsvalue)

### func call\<T>(ToJSValue, Array\<T>) where T <: ToJSValue

```cangjie
public func call<T>(thisArg: ToJSValue, args: Array<T>): JSValue where T <: ToJSValue
```

**功能：** 以指定的 this 对象和参数列表调用 JavaScript 函数。

**参数：**

| 参数名  | 类型                              | 必填 | 默认值 | 说明        |
| :------ | :-------------------------------- | :--- | :----- | :---------- |
| thisArg | [ToJSValue](#interface-tojsvalue) | 是   | -      | this 对象。 |
| args    | Array<T>                          | 是   | -      | 参数列表。  |

**返回值：**

| 类型                       | 说明                 |
| :------------------------- | :------------------- |
| [JSValue](#class-jsvalue) | 函数调用的返回结果。 |

### func globalCall\<T>(Array\<T>) where T <: ToJSValue

```cangjie
public func globalCall<T>(args: Array<T>): JSValue where T <: ToJSValue
```

**功能：** 在全局对象中以指定的参数列表调用 JavaScript 函数。

**参数：**

| 参数名 | 类型     | 必填 | 默认值 | 说明       |
| :----- | :------- | :--- | :----- | :--------- |
| args   | Array<T> | 是   | -      | 参数列表。 |

**返回值：**

| 类型                       | 说明                 |
| :------------------------- | :------------------- |
| [JSValue](#class-jsvalue) | 函数调用的返回结果。 |

## class JSHeapObject

```cangjie
abstract sealed class JSHeapObject <: ToJSValue {}
```

**功能：** 作为所有跨语言强引用类型的父类，保证引用期间数据不会被 JavaScript 运行时回收，在数据使用结束时自动释放对 JavaScript 数据的引用，提供引用类型转换为 JSValue 的功能。

**父类型：**

* ToString

### func toJSValue()

```cangjie
func toJSValue(): JSValue
```

**功能：** 将仓颉类型转换为 JSValue。

**返回值：**

| 类型                       | 说明                  |
| :------------------------- | :-------------------- |
| [JSValue](#class-jsvalue) | JavaScript 统一类型。 |

## class JSMap

```cangjie
public class JSMap <: JSHeapObject & FromJSValue<JSMap> {}
```

**功能：** 对 JavaScript 映射对象进行跨语言强引用，用来获取键值对数量、对键值对进行增删改查。

**父类型：**

* [JSHeapObject](#class-jsheapobject)
* [FromJSValue](#interface-fromjsvalue)

### prop size

```cangjie
public prop size: Int64
```

**功能：** 获取键值对数量。

**类型：** Int64

**可读写性：** 只读

### func deleteProperty(ToJSValue)

```cangjie
public func deleteProperty(key: ToJSValue): Bool
```

**功能：** 删除指定键的键值对。

**参数：**

| 参数名 | 类型                              | 必填 | 默认值 | 说明               |
| :----- | :-------------------------------- | :--- | :----- | :----------------- |
| key    | [ToJSValue](#interface-tojsvalue) | 是   | -      | 待删除键值对的键。 |

**返回值：**

| 类型 | 说明           |
| :--- | :------------- |
| Bool | 是否删除成功。 |

### func hasProperty(ToJSValue)

```cangjie
public func hasProperty(key: ToJSValue): Bool
```

**功能：** 查询是否有给定的键。

**参数：**

| 参数名 | 类型                              | 必填 | 默认值 | 说明         |
| :----- | :-------------------------------- | :--- | :----- | :----------- |
| key    | [ToJSValue](#interface-tojsvalue) | 是   | -      | 待查询的键。 |

**返回值：**

| 类型 | 说明           |
| :--- | :------------- |
| Bool | 是否包含属性。 |

### func keys()

```cangjie
public func keys(): JSArray
```

**功能：** 获取所有键的列表。

**返回值：**

| 类型                      | 说明           |
| :------------------------ | :------------- |
| [JSArray](#class-jsarray) | 所有键的列表。 |

### func \[](ToJSValue)

```cangjie
public operator func[](key: ToJSValue): JSValue
```

**功能：** 读取指定键对应的值。

**参数：**

| 参数名 | 类型                              | 必填 | 默认值 | 说明           |
| :----- | :-------------------------------- | :--- | :----- | :------------- |
| key    | [ToJSValue](#interface-tojsvalue) | 是   | -      | 待读取值的键。 |

**返回值：**

| 类型                       | 说明             |
| :------------------------- | :--------------- |
| [JSValue](#class-jsvalue) | 指定键对应的值。 |

### func \[](ToJSValue, ToJSValue)

```cangjie
public operator func[](key: ToJSValue, value!: ToJSValue): Unit
```

**功能：** 增加给定的键值对。

**参数：**

| 参数名 | 类型                              | 必填 | 默认值 | 说明         |
| :----- | :-------------------------------- | :--- | :----- | :----------- |
| key    | [ToJSValue](#interface-tojsvalue) | 是   | -      | 待增加的键。 |
| value  | [ToJSValue](#interface-tojsvalue) | 是   | -      | 待增加的值。 |

## class JSNull

```cangjie
public class JSNull {}
```

**功能：** 对 JavaScript Null 对象进行弱引用。

## class JSNumber

```cangjie
public class JSNumber {}
```

**功能：** 对 JavaScript 数字对象进行弱引用，用来转换为仓颉数字。

### func toFloat64()

```cangjie
public func toFloat64(): Float64
```

**功能：** 将 JavaScript 数字对象转换为仓颉双精度浮点数。

**返回值：**

| 类型    | 说明                         |
| :------ | :--------------------------- |
| Float64 | 转换得到的仓颉双精度浮点数。 |

### func toInt32()

```cangjie
public func toInt32(): Int32
```

**功能：** 转换为仓颉 32 位整数。

**返回值：**

| 类型  | 说明                       |
| :---- | :------------------------- |
| Int32 | 转换得到的仓颉 32 位整数。 |

### func toInt64()

```cangjie
public func toInt64(): Int64
```

**功能：** 转换为仓颉 64 位整数。

**返回值：**

| 类型  | 说明                       |
| :---- | :------------------------- |
| Int64 | 转换得到的仓颉 64 位整数。 |

### func toUint32()

```cangjie
public func toUint32(): UInt32
```

**功能：** 转换为仓颉无符号 32 位整数。

**返回值：**

| 类型   | 说明                             |
| :----- | :------------------------------- |
| UInt32 | 转换得到的仓颉无符号 32 位整数。 |

## class JSObject

```cangjie
public class JSObject <: JSHeapObject & FromJSValue<JSObject> {}
```

**功能：** 对 JavaScript 对象进行跨语言强引用，用来获取属性数量、对属性进行增删改查。

**父类型：**

* [JSHeapObject](#class-jsheapobject)
* [FromJSValue](#interface-fromjsvalue)

### prop size

```cangjie
public prop size: Int64
```

**功能：** 获取属性数量。

**类型：** Int64

**可读写性：** 只读

### func deleteProperty(JSKeyable)

```cangjie
public func deleteProperty(key: JSKeyable): Bool
```

**功能：** 删除指定键的属性。

**参数：**

| 参数名 | 类型                              | 必填 | 默认值 | 说明             |
| :----- | :-------------------------------- | :--- | :----- | :--------------- |
| key    | [JSKeyable](#interface-jskeyable) | 是   | -      | 待删除属性的键。 |

**返回值：**

| 类型 | 说明           |
| :--- | :------------- |
| Bool | 是否删除成功。 |

### func getPropertyNames()

```cangjie
public func getPropertyNames(): JSArray
```

**功能：** 获取属性列表。

**返回值：**

| 类型                      | 说明       |
| :------------------------ | :--------- |
| [JSArray](#class-jsarray) | 属性列表。 |

### func hasProperty(JSKeyable)

```cangjie
public func hasProperty(key: JSKeyable): Bool
```

**功能：** 以给定的键查询是否有对应的属性。

**参数：**

| 参数名 | 类型                              | 必填 | 默认值 | 说明             |
| :----- | :-------------------------------- | :--- | :----- | :--------------- |
| key    | [JSKeyable](#interface-jskeyable) | 是   | -      | 待查询属性的键。 |

**返回值：**

| 类型 | 说明           |
| :--- | :------------- |
| Bool | 是否包含属性。 |

### func \[](JSKeyable)

```cangjie
public operator func[](key: JSKeyable): JSValue
```

**功能：** 读取指定键对应的属性。

**参数：**

| 参数名 | 类型                              | 必填 | 默认值 | 说明             |
| :----- | :-------------------------------- | :--- | :----- | :--------------- |
| key    | [JSKeyable](#interface-jskeyable) | 是   | -      | 待读取属性的键。 |

**返回值：**

| 类型                       | 说明               |
| :------------------------- | :----------------- |
| [JSValue](#class-jsvalue) | 指定键对应的属性。 |

### func \[](JSKeyable, ToJSValue)

```cangjie
public operator func[](key: JSKeyable, value!: ToJSValue): Unit
```

**功能：** 以给定的键值对增加属性。

**参数：**

| 参数名 | 类型                              | 必填 | 默认值 | 说明             |
| :----- | :-------------------------------- | :--- | :----- | :--------------- |
| key    | [JSKeyable](#interface-jskeyable) | 是   | -      | 待增加属性的键。 |
| value  | [ToJSValue](#interface-tojsvalue) | 是   | -      | 待增加的属性。   |

## class JSRuntime

```cangjie
public class JSRuntime {}
```

**功能：** 对 JavaScript 运行时实例进行引用，用来创建和管理 JSValue 上下文。

### prop mainContext

```cangjie
public prop mainContext: JSContext
```

**功能：** 创建上下文。

**类型：** [JSContext](#class-jscontext)

**可读写性：** 只读

### static func create()

```cangjie
public static func create(): JSRuntime
```

**功能：** 创建 JavaScript 运行时实例。

**返回值：**

| 类型                          | 说明                    |
| :---------------------------- | :---------------------- |
| [JSRuntime](#class-jsruntime) | JavaScript 运行时实例。 |

### func destroy()

```cangjie
public func destroy(): Unit
```

**功能：** 销毁此运行时实例。

### func getHeapStats()

```cangjie
public func getHeapStats(): JSVM_HeapStatistics
```

**功能：** 获取此运行时实例的堆信息。

**返回值：**

| 类型                               | 说明             |
| :--------------------------------- | :--------------- |
| [JSVM_HeapStatistics](#struct-jsvm_heapstatistics) | 获取到的堆信息。 |

### func isDestroyed()

```cangjie
public func isDestroyed(): Bool
```

**功能：** 判断此运行时实例是否已销毁。

**返回值：**

| 类型 | 说明         |
| :--- | :----------- |
| Bool | 是否已销毁。 |

## class JSString

```cangjie
public class JSString <: JSHeapObject & FromJSValue<JSString> & JSKeyable {}
```

**功能：** 对 JavaScript 字符串进行跨语言强引用，用来转换为仓颉字符串。

**父类型：**

* [JSHeapObject](#class-jsheapobject)
* [FromJSValue](#interface-fromjsvalue)
* [JSKeyable](#interface-jskeyable)

### func toString()

```cangjie
public func toString(): String
```

**功能：** 将 JavaScript 字符串转换为仓颉字符串。

**返回值：**

| 类型   | 说明                   |
| :----- | :--------------------- |
| String | 转换得到的仓颉字符串。 |

## class JSUndefined

```cangjie
public class JSUndefined {}
```

**功能：** 对 JavaScript JSUndefined 对象进行弱引用。

## class JSValue

```cangjie
public class JSValue <: ToJSValue & FromJSValue<JSValue> {}
```

**功能：** 对 JavaScript 统一类型对象进行弱引用，直接参与数据交互，用来做类型判断、转换为仓颉类型和转换为仓颉对 JavaScript 数据的引用。

**父类型：**

* [ToJSValue](#interface-tojsvalue)
* [FromJSValue](#interface-fromjsvalue)

### func asArray()

```cangjie
public func asArray(): JSArray
```

**功能：** 转换为 JSArray。

**返回值：**

| 类型                      | 说明             |
| :------------------------ | :--------------- |
| [JSArray](#class-jsarray) | 转换得到的数据。 |

### func asBoolean()

```cangjie
public func asBoolean(): JSBoolean
```

**功能：** 转换为 JSBoolean。

**返回值：**

| 类型                           | 说明             |
| :----------------------------- | :--------------- |
| [JSBoolean](#class-jsboolean) | 转换得到的数据。 |

### func asFunction()

```cangjie
public func asFunction(): JSFunction
```

**功能：** 转换为 JSFunction。

**返回值：**

| 类型                            | 说明             |
| :------------------------------ | :--------------- |
| [JSFunction](#class-jsfunction) | 转换得到的数据。 |

### func asMap()

```cangjie
public func asObject(): JSMap
```

**功能：** 转换为 JSMap。

**返回值：**

| 类型                  | 说明             |
| :-------------------- | :--------------- |
| [JSMap](#class-jsmap) | 转换得到的数据。 |

### func asNull()

```cangjie
public func asNull(): JSNull
```

**功能：** 转换为 JSNull。

**返回值：**

| 类型                     | 说明             |
| :----------------------- | :--------------- |
| [JSNull](#class-jsnull) | 转换得到的数据。 |

### func asNumber()

```cangjie
public func asNumber(): JSNumber
```

**功能：** 转换为 JSNumber。

**返回值：**

| 类型                         | 说明             |
| :--------------------------- | :--------------- |
| [JSNumber](#class-jsnumber) | 转换得到的数据。 |

### func asObject()

```cangjie
public func asObject(): JSObject
```

**功能：** 转换为 JSObject。

**返回值：**

| 类型                        | 说明             |
| :-------------------------- | :--------------- |
| [JSObject](#class-jsobject) | 转换得到的数据。 |

### func asString()

```cangjie
public func asString(): JSString
```

**功能：** 转换为 JSString.

**返回值：**

| 类型                        | 说明             |
| :-------------------------- | :--------------- |
| [JSString](#class-jsstring) | 转换得到的数据。 |

### func asUndefined()

```cangjie
public func asUndefined(): JSUndefined
```

**功能：** 转换为 JSUndefined。

**返回值：**

| 类型                               | 说明             |
| :--------------------------------- | :--------------- |
| [JSUndefined](#class-jsundefined) | 转换得到的数据。 |

### func isArray()

```cangjie
public func isArray(): Bool
```

**功能：** 判断是否是 Array 类型。

**返回值：**

| 类型 | 说明                |
| :--- | :------------------ |
| Bool | 是否是 Array 类型。 |

### func isBigInt()

```cangjie
public func isBigInt(): Bool
```

**功能：** 判断是否是 BigInt 类型。

**返回值：**

| 类型 | 说明                 |
| :--- | :------------------- |
| Bool | 是否是 BigInt 类型。 |

### func isBoolean()

```cangjie
public func isBoolean(): Bool
```

**功能：** 判断是否是 Boolean 类型。

**返回值：**

| 类型 | 说明                  |
| :--- | :-------------------- |
| Bool | 是否是 Boolean 类型。 |

### func isExternal()

```cangjie
public func isExternal(): Bool
```

**功能：** 判断是否是 External 类型。

**返回值：**

| 类型 | 说明                   |
| :--- | :--------------------- |
| Bool | 是否是 External 类型。 |

### func isFunction()

```cangjie
public func isFunction(): Bool
```

**功能：** 判断是否是 Function 类型。

**返回值：**

| 类型 | 说明                   |
| :--- | :--------------------- |
| Bool | 是否是 Function 类型。 |

### func isMap()

```cangjie
public func isObject(): Bool
```

**功能：** 判断是否是 Map 类型。

**返回值：**

| 类型 | 说明              |
| :--- | :---------------- |
| Bool | 是否是 Map 类型。 |

### func isNull()

```cangjie
public func isNull(): Bool
```

**功能：** 判断是否是 Null 类型。

**返回值：**

| 类型 | 说明               |
| :--- | :----------------- |
| Bool | 是否是 Null 类型。 |

### func isNullOrUndefined()

```cangjie
public func isNullOrUndefined(): Bool
```

**功能：** 判断是否是 Null 或 Undefined 类型。

**返回值：**

| 类型 | 说明                            |
| :--- | :------------------------------ |
| Bool | 是否是 Null 或 Undefined 类型。 |

### func isNumber()

```cangjie
public func isNumber(): Bool
```

**功能：** 判断是否是 Number 类型。

**返回值：**

| 类型 | 说明                 |
| :--- | :------------------- |
| Bool | 是否是 Number 类型。 |

### func isObject()

```cangjie
public func isObject(): Bool
```

**功能：** 判断是否是 Object 类型。

**返回值：**

| 类型 | 说明                 |
| :--- | :------------------- |
| Bool | 是否是 Object 类型。 |

### func isPromise()

```cangjie
public func isPromise(): Bool
```

**功能：** 判断是否是 Promise 类型。

**返回值：**

| 类型 | 说明                  |
| :--- | :-------------------- |
| Bool | 是否是 Promise 类型。 |

### func isString()

```cangjie
public func isString(): Bool
```

**功能：** 判断是否是 String 类型。

**返回值：**

| 类型 | 说明                 |
| :--- | :------------------- |
| Bool | 是否是 String 类型。 |

### func isSymbol()

```cangjie
public func isSymbol(): Bool
```

**功能：** 判断是否是 Symbol 类型。

**返回值：**

| 类型 | 说明                 |
| :--- | :------------------- |
| Bool | 是否是 Symbol 类型。 |

### func isUndefined()

```cangjie
public func isUndefined(): Bool
```

**功能：** 判断是否是 Undefined 类型。

**返回值：**

| 类型 | 说明                    |
| :--- | :---------------------- |
| Bool | 是否是 Undefined 类型。 |

### func toBool()

```cangjie
public func toBool(): Bool
```

**功能：** 转换为仓颉布尔值。

**返回值：**

| 类型 | 说明                   |
| :--- | :--------------------- |
| Bool | 转换得到的仓颉布尔值。 |

### func toNumberFloat64()

```cangjie
public func toNumberFloat64(): Float64
```

**功能：** 转换为仓颉双精度浮点数。

**返回值：**

| 类型    | 说明                         |
| :------ | :--------------------------- |
| Float64 | 转换得到的仓颉双精度浮点数。 |

### func toNumberInt32()

```cangjie
public func toNumberInt32(): Int32
```

**功能：** 转换为仓颉 32 位整数。

**返回值：**

| 类型  | 说明                       |
| :---- | :------------------------- |
| Int32 | 转换得到的仓颉 32 位整数。 |

### func toNumberInt64()

```cangjie
public func toNumberInt64(): Int64
```

**功能：** 转换为仓颉 64 位整数。

**返回值：**

| 类型  | 说明                       |
| :---- | :------------------------- |
| Int64 | 转换得到的仓颉 64 位整数。 |

### func toNumberUint32()

```cangjie
public func toNumberUint32(): UInt32
```

**功能：** 转换为仓颉无符号 32 位整数。

**返回值：**

| 类型   | 说明                             |
| :----- | :------------------------------- |
| UInt32 | 转换得到的仓颉无符号 32 位整数。 |

### func toString()

```cangjie
public func toString(): String
```

**功能：** 转换为仓颉字符串。

**返回值：**

| 类型   | 说明                   |
| :----- | :--------------------- |
| String | 转换得到的仓颉字符串。 |

### func typeOf()

```cangjie
public func typeOf(): JSVM_ValueType
```

**功能：** 获取 JavaScript 统一类型对象的实际类型。

**返回值：**

| 类型                     | 说明                     |
| :----------------------- | :----------------------- |
| [JSVM_ValueType](#struct-jsvm_valuetype) | 具体的 JavaScript 类型。 |

## struct JSCallInfo

```cangjie
public struct JSCallInfo {}
```

**功能：** 存储 JavaScript 调用仓颉函数时的调用信息，用来获取参数列表和 this 对象。

### prop args

```cangjie
public prop args: Array<JSValue>
```

**功能：** 获取参数列表。

**类型：** Array<[JSValue](#class-jsvalue)>

**可读写性：** 只读

### prop thisArg

```cangjie
public prop thisArg: JSValue
```

**功能：** 获取 this 对象。

**类型：** [JSValue](#class-jsvalue)

**可读写性：** 只读

### prop size

```cangjie
public prop size: Int64
```

**功能：** 获取参数个数。

**类型：** Int64

**可读写性：** 只读

### func \[](Int64)

```cangjie
public operator func[](index: Int64): JSValue
```

**功能：** 读取指定位置的参数。

**参数：**

| 参数名 | 类型  | 必填 | 默认值 | 说明               |
| :----- | :---- | :--- | :----- | :----------------- |
| index  | Int64 | 是   | -      | 待读取参数的位置。 |

**返回值：**

| 类型                       | 说明             |
| :------------------------- | :--------------- |
| [JSValue](#class-jsvalue) | 指定位置的参数。 |

## struct JSCodeCache

```cangjie
public struct JSCodeCache {}
```

**功能：** 存储 JavaScript 代码缓存。

## struct JSVM_HeapStatistics

```cangjie
public struct JSVM_HeapStatistics <: ToString {}
```

**功能：** 存储 JavaScript 运行时的堆信息，用来将堆信息转换为字符串描述。

**父类型：**

* ToString

### func toString()

```cangjie
public func toString(): String
```

**功能：** 将 JavaScript 运行时的堆信息转换为仓颉字符串描述。

**返回值：**

| 类型   | 说明                       |
| :----- | :------------------------- |
| String | 转换得到的仓颉字符串描述。 |

## struct JSVM_ValueType

```cangjie
public struct JSVM_ValueType {}
```

**功能：** 表示 JavaScript 数据的大致类型。

### static let BIGINT

```cangjie
public static let BIGINT: JSVM_ValueType
```

**功能：** 表示 BigInt 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### static let BOOLEAN

```cangjie
public static let BOOLEAN: JSVM_ValueType
```

**功能：** 表示 Boolean 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### static let EXTERNAL

```cangjie
public static let EXTERNAL: JSVM_ValueType
```

**功能：** 表示 External 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### static let FUNCTION

```cangjie
public static let FUNCTION: JSVM_ValueType
```

**功能：** 表示 Function 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### static let NULL

```cangjie
public static let NULL: JSVM_ValueType
```

**功能：** 表示 Null 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### static let NUMBER

```cangjie
public static let NUMBER: JSVM_ValueType
```

**功能：** 表示 Number 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### static let OBJECT

```cangjie
public static let OBJECT: JSVM_ValueType
```

**功能：** 表示 Object 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### static let STRING

```cangjie
public static let STRING: JSVM_ValueType
```

**功能：** 表示 String 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### static let SYMBOL

```cangjie
public static let SYMBOL: JSVM_ValueType
```

**功能：** 表示 Symbol 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### static let UNDEFINED

```cangjie
public static let UNDEFINED: JSVM_ValueType
```

**功能：** 表示 Undefined 类型。

**类型：** [JSVM_ValueType](#struct-jsvm_valuetype)

**可读写性：** 只读

### func toString()

```cangjie
public func toString(): String
```

**功能：** 将 JSVM_ValueType 转换为仓颉字符串描述。

**返回值：**

| 类型   | 说明                       |
| :----- | :------------------------- |
| String | 转换得到的仓颉字符串描述。 |

### func !=(JSVM_ValueType)

```cangjie
public operator func !=(target: JSVM_ValueType): Bool
```

**功能：** 判断两个 JSVM_ValueType 是否是不同类型。

**返回值：**

| 类型 | 说明                         |
| :--- | :--------------------------- |
| Bool | 两个 JSVM_ValueType 是否是不同类型。 |

### func ==(JSVM_ValueType)

```cangjie
public operator func ==(target: JSVM_ValueType): Bool
```

**功能：** 判断两个 JSVM_ValueType 是否是相同类型。

**返回值：**

| 类型 | 说明                         |
| :--- | :--------------------------- |
| Bool | 两个 JSVM_ValueType 是否是相同类型。 |

## type JSLambda

```cangjie
public type JSLambda = (JSContext, JSCallInfo) -> JSValue
```

**功能：** 固定类型的仓颉函数的类型别名，用来创建 JavaScript 函数对象。

**类型：** ([JSContext](#class-jscontext), [JSCallInfo](#struct-jscallinfo)) -> [JSValue](#class-jsvalue)