import Foundation

public func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    var items = items
    items.insert("ℹ️", at: 0)
    _log(items, separator: separator, terminator: terminator)
}

public func logWarning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    var items = items
    items.insert("⚠️", at: 0)
    _log(items, separator: separator, terminator: terminator)
}

public func logError(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    var items = items
    items.insert("❌", at: 0)
    _log(items, separator: separator, terminator: terminator)
}

public func logMagic(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    var items = items
    items.insert("🦄", at: 0)
    _log(items, separator: separator, terminator: terminator)
}

public func logHack(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    var items = items
    items.insert("💩", at: 0)
    _log(items, separator: separator, terminator: terminator)
}
