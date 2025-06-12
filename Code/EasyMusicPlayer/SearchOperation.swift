import Foundation
import MediaPlayer

final class SearchOperation: Operation, @unchecked Sendable {
    private let allTracks: [MPMediaItem]
    private let query: String
    private let completion: ([MPMediaItem]) -> Void

    init(
        query: String,
        allTracks: [MPMediaItem],
        completion: @escaping ([MPMediaItem]) -> Void
    ) {
        self.query = query
        self.allTracks = allTracks
        self.completion = completion
    }

    override func main() {
        guard !isCancelled else { return }

        let tracks = allTracks.filter {
            ($0.title?.localizedCaseInsensitiveContains(query) ?? false) ||
            ($0.artist?.localizedCaseInsensitiveContains(query) ?? false) ||
            ($0.albumTitle?.localizedCaseInsensitiveContains(query) ?? false) ||
            ($0.genre?.localizedCaseInsensitiveContains(query) ?? false)
        }

        guard !isCancelled else { return }

        Task { @MainActor in
            completion(tracks)
        }
    }
}
