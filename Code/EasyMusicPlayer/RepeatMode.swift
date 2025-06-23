import Foundation
import MediaPlayer

enum RepeatMode: String, Sendable {
    case none
    case one
    case all
}

extension RepeatMode {
    var remote: MPRepeatType {
        switch self {
        case .none:
            return .off
        case .one:
            return .one
        case .all:
            return .all
        }
    }

    func next() -> RepeatMode {
        switch self {
        case .none:
            return .one
        case .one:
            return .all
        case .all:
            return .none
        }
    }

    mutating func toggle() {
        switch self {
        case .none:
            self = .one
        case .one:
            self = .all
        case .all:
            self = .none
        }
    }
}

extension MPRepeatType {
    var repeatMode: RepeatMode {
        switch self {
        case .off:
            return .none
        case .one:
            return .one
        case .all:
            return .all
        default:
            assertionFailure("unhandled MPRepeatType")
            return .none
        }
    }
}
