import Foundation

public protocol Log {
    static var isEnabled: Bool { get set }
    static var description: String { get }

    static func info(_ items: Any..., separator: String, terminator: String)
    static func warning(_ items: Any..., separator: String, terminator: String)
    static func error(_ items: Any..., separator: String, terminator: String)
    static func magic(_ items: Any..., separator: String, terminator: String)
    static func hack(_ items: Any..., separator: String, terminator: String)
}

public extension Log {
    static var description: String {
        return "\(self):"
    }

    static func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard isEnabled else { return }
        var items = items
        items.insert(description, at: 0)
        items.insert("ℹ️", at: 0)
        _log(items, separator: separator, terminator: terminator)
    }

    static func warning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard isEnabled else { return }
        var items = items
        items.insert(description, at: 0)
        items.insert("⚠️", at: 0)
        _log(items, separator: separator, terminator: terminator)
    }

    static func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard isEnabled else { return }
        var items = items
        items.insert(description, at: 0)
        items.insert("❌", at: 0)
        _log(items, separator: separator, terminator: terminator)
    }

    static func magic(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard isEnabled else { return }
        var items = items
        items.insert(description, at: 0)
        items.insert("🦄", at: 0)
        _log(items, separator: separator, terminator: terminator)
    }

    static func hack(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard isEnabled else { return }
        var items = items
        items.insert(description, at: 0)
        items.insert("💩", at: 0)
        _log(items, separator: separator, terminator: terminator)
    }
}
