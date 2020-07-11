import Foundation

protocol CellIdentifiable {
    static var reuseIdentifier: String { get }
}

extension CellIdentifiable {
    // defaults to class name if not implemented
    static var reuseIdentifier: String {
        return "\(self)"
    }
}
