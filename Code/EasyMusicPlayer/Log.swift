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

// swiftlint:disable identifier_name cyclomatic_complexity
// outputs only in DEBUG mode
func _log(_ items: Any..., separator s: String = " ", terminator t: String = "\n") {
    #if DEBUG

    guard let i = items[0] as? [Any] else {
        assertionFailure("expected [Any]")
        return
    }

    // when just calling print(), print turns Any...[] into [[Any]], meaning the separator is ignored
    switch i.count {
    case 1:
        print(i[0], separator: s, terminator: t)
    case 2:
        print(i[0], i[1], separator: s, terminator: t)
    case 3:
        print(i[0], i[1], i[2], separator: s, terminator: t)
    case 4:
        print(i[0], i[1], i[2], i[3], separator: s, terminator: t)
    case 5:
        print(i[0], i[1], i[2], i[3], i[4], separator: s, terminator: t)
    case 6:
        print(i[0], i[1], i[2], i[3], i[4], i[5], separator: s, terminator: t)
    case 7:
        print(i[0], i[1], i[2], i[3], i[4], i[5], i[6], separator: s, terminator: t)
    case 8:
        print(i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7], separator: s, terminator: t)
    case 9:
        print(i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7], i[8], separator: s, terminator: t)
    case 10:
        print(i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7], i[8], i[9], separator: s, terminator: t)
    default:
        print(i, separator: s, terminator: t)
    }

    #endif
}
