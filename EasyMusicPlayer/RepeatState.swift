import Foundation
import MediaPlayer

enum RepeatState: String {
    case none
    case one
    case all
}

extension RepeatState {
    var remoteRepeatType: MPRepeatType {
        switch self {
        case .none:
            return .off
        case .one:
            return .one
        case .all:
            return .all
        }
    }

    func next() -> RepeatState {
        switch self {
        case .none:
            return .one
        case .one:
            return .all
        case .all:
            return .none
        }
    }
}

extension MPRepeatType {
    var repeatState: RepeatState {
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
