import Foundation

enum SearchAction {
    case select(Track)
    case search(String?)
    case done
}
