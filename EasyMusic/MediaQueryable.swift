import Foundation
import MediaPlayer

protocol MediaQueryable {
    static func songs() -> MPMediaQuery
}
extension MPMediaQuery: MediaQueryable {}
