import Combine
import MediaPlayer
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var tracks = [MPMediaItem]()
    @Published var isLoading = false {
        didSet { isProgressViewHidden = !isLoading }
    }
    @Published var isProgressViewHidden = false
    @Published var isSearchDisabled = true
    @Published var isListDisabled = true
    @Published var isNotFoundTextHidden = true
    @Published var notFoundTextColor: Color = .clear

    let searchPrompt = L10n.searchViewTitle
    let notFoundText = L10n.searchViewEmptyText

    private let musicPlayer: MusicPlayable
    private let soundEffects: SoundEffecting
    private var cancellables = [AnyCancellable]()
    private var allTracks = [MPMediaItem]()
    private let doneAction: () -> Void
    private var task: Task<Void, Never>?
    private let queue: Queue

    init(
        musicPlayer: MusicPlayable,
        soundEffects: SoundEffecting,
        queue: Queue = OperationQueue(),
        doneAction: @escaping () -> Void
    ) {
        self.musicPlayer = musicPlayer
        self.soundEffects = soundEffects
        self.doneAction = doneAction
        self.queue = queue

        setup()
        sortTracks()
    }

    func select(_ track: MPMediaItem) {
        soundEffects.play(.casette)
        musicPlayer.play(track)
        doneAction()
    }

    private func sortTracks() {
        isLoading = true

        queue.addOperation { [weak self] in
            guard let self else { return }
            let tracks = musicPlayer.info.tracks.sorted(by: { $0.sortID < $1.sortID })
            DispatchQueue.main.async {
                self.allTracks = tracks
                self.tracks = tracks
                self.isLoading = false
                self.isSearchDisabled = false
                self.isListDisabled = false
            }
        }
    }

    private func setup() {
        queue.maxConcurrentOperationCount = 1

        $searchText
            .dropFirst()
            .sink { [weak self] in
                self?.search($0)
            }
            .store(in: &cancellables)
    }

    private func search(_ query: String) {
        isNotFoundTextHidden = true

        guard !query.isEmpty else {
            tracks = allTracks
            return
        }

        isLoading = true
        isListDisabled = true

        queue.cancelAllOperations()

        let allTracks = self.allTracks
        queue.addOperation { [weak self] in
            guard let self else { return }
            // swiftlint:disable line_length
            let predicate = NSPredicate(format: "title contains[cd] %@ OR artist contains[cd] %@ OR albumTitle contains[cd] %@ OR genre contains[cd] %@", query, query, query, query)
            let tracks = NSArray(array: allTracks).filtered(using: predicate) as! [MPMediaItem]

            DispatchQueue.main.async {
                self.tracks = tracks
                self.isNotFoundTextHidden = !tracks.isEmpty
                self.isLoading = false
                self.isListDisabled = false
            }
        }
    }
}
