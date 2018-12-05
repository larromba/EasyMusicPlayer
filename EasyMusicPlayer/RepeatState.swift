import Foundation

enum RepeatState: String {
    case none
    case one
    case all
}

extension RepeatState {
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
