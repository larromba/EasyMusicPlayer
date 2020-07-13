import BaseOperation
import Foundation
import Logging
import MediaPlayer

final class SearchOperation: BaseOperation {
    private let tracks: [MPMediaItem]
    private let completion: ([MPMediaItem]) -> Void
    private let text: String

    init(tracks: [MPMediaItem], text: String, completion: @escaping ([MPMediaItem]) -> Void) {
        self.tracks = tracks
        self.text = text
        self.completion = completion
    }

    override func execute() {
        //swiftlint:disable line_length
        let predicate = NSPredicate(format: "title contains[cd] %@ OR artist contains[cd] %@ OR albumTitle contains[cd] %@ OR genre contains[cd] %@", text, text, text, text)
        let filteredItems = NSArray(array: tracks).filtered(using: predicate) as! [MPMediaItem]
        guard !self.isCancelled else {
            logError("didn't finish SearchOperation (already cancelled)")
            finish()
            return
        }
        DispatchQueue.main.async {
            log("did finish SearchOperation")
            self.completion(filteredItems)
            self.finish()
        }
    }

    override func cancel() {
        super.cancel()
        logWarning("cancelling SearchOperation")
        finish()
    }
}
