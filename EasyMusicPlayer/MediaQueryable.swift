import Foundation
import MediaPlayer

// sourcery: name = MediaQuery
protocol MediaQueryable: Mockable {
    static func songs() -> MPMediaQuery
    static func search(_ text: String) -> [MPMediaItem]
}
extension MPMediaQuery: MediaQueryable {
    #if DEBUG && targetEnvironment(simulator)
    static func songs() -> MPMediaQuery {
        return DummyMediaQuery()
    }
    #endif

    static func search(_ text: String) -> [MPMediaItem] {
        //swiftlint:disable line_length
        let predicate = NSPredicate(format: "title contains[cd] %@ OR albumTitle contains[cd] %@ OR artist contains[cd] %@ OR genre contains[cd] %@", text, text, text, text)
        guard let items = songs().items,
            let filteredItems = NSArray(array: items).filtered(using: predicate) as? [MPMediaItem] else { return [] }
        return filteredItems
    }
}
