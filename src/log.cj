// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package js_interop

import ohos.hilog.*
public enum LogLevel <: ToString {
    | ERROR
    | WARN
    | INFO
    | DEBUG

    public func level(): Int32 {
        let num = match (this) {
            case ERROR => 0
            case WARN => 1
            case INFO => 2
            case DEBUG => 3
        }
        return Int32(num)
    }

    public func toString(): String {
        match (this) {
            case ERROR => "ERROR"
            case WARN => "WARN"
            case INFO => "INFO"
            case DEBUG => "DEBUG"
        }
    }
}

public class JSLogger {
    // 宿主注入日志打印，实现日志回捞
    public static var matrixLog = Option<(Int32, String, String) -> Unit>.None
    private var level_ = LogLevel.WARN

    public mut prop level: LogLevel {
        get() {
            level_
        }
        set(level_) {
            this.level_ = level_
        }
    }

    public func debug(msg: String): Unit {
        log(LogLevel.DEBUG, msg)
    }

    public func info(msg: String): Unit {
        log(LogLevel.INFO, msg)
    }

    public func warn(msg: String): Unit {
        log(LogLevel.WARN, msg)
    }

    public func error(msg: String): Unit {
        log(LogLevel.ERROR, msg)
    }
    public func log(level: LogLevel, msg: String): Unit {
        if (this.level_.level() < level.level()) {
            return
        }
        if (let Some(v) <- matrixLog) {
            v(level.level(), "JSLog", msg)
        }
    }
}

public let JSLOG: JSLogger = JSLogger()