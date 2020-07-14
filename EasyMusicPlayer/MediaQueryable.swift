import Foundation
import MediaPlayer

// sourcery: name = MediaQuery
protocol MediaQueryable: Mockable {
    static func songs() -> MPMediaQuery
}
extension MPMediaQuery: MediaQueryable {
    #if DEBUG && targetEnvironment(simulator)
    private static let library: [MPMediaItem] = {
        // REINSTALL APP ON SIMULATOR AFTER CHANGING THIS

        // use to test a small, specific library
        return [DummyMediaItem(asset: .normal, id: 0),
                DummyMediaItem(asset: .endSilence, id: 1),
                DummyMediaItem(asset: .normal, id: 2)]

    //        // use to test a large number of items - might be slow on load
    //        return (0..<50_000).map {
    //            DummyMediaItem(asset: .normal, artist: UUID().uuidString, title: UUID().uuidString, id: $0)
    //        }
    }()

    static func songs() -> MPMediaQuery {
        return DummyMediaQuery(items: library)
    }
    #endif
}
