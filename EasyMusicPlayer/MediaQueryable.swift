import Foundation
import MediaPlayer

// sourcery: name = MediaQuery
protocol MediaQueryable: Mockable {
    // sourcery: returnValue = "TestMediaQuery(items: [MockMediaItem()])"
    static func songs() -> MPMediaQuery
}
extension MPMediaQuery: MediaQueryable {}
