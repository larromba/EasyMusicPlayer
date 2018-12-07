import Foundation
import MediaPlayer

// sourcery: name = MediaQuery
protocol MediaQueryable: Mockable {
    static func songs() -> MPMediaQuery
}
extension MPMediaQuery: MediaQueryable {}
