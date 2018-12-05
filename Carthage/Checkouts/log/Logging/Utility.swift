import Foundation

// want to use print functionality, but print turns Any...[] into [[Any]], meaning the separator is ignored
// swiftlint:disable identifier_name cyclomatic_complexity
func _log(_ items: Any..., separator s: String = " ", terminator t: String = "\n") {
    guard let i = items[0] as? [Any] else {
        assertionFailure("expected [Any]")
        return
    }
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
}
