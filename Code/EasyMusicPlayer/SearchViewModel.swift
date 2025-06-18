import Combine
@preconcurrency import MediaPlayer
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var tracks = [MPMediaItem]()
    @Published var isLoading = false
    @Published var isSearchDisabled = true
    @Published var isNotFoundTextHidden = true
    @Published var notFoundTextColor: Color = .clear

    var isListDisabled: Bool { isLoading }
    var isProgressViewHidden: Bool { !isLoading }
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
            let tracks = musicPlayer.info.tracks.sorted {
                $0.sortID.localizedCaseInsensitiveCompare($1.sortID) == .orderedAscending
            }
            Task { @MainActor in
                self.allTracks = tracks
                self.tracks = tracks
                self.isLoading = false
                self.isSearchDisabled = false
            }
        }
    }

    private func setup() {
        queue.maxConcurrentOperationCount = 1

        $searchText
            .dropFirst()
            .removeDuplicates()
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.search($0)
            }
            .store(in: &cancellables)
    }

    private func search(_ query: String) {
        queue.cancelAllOperations()

        isNotFoundTextHidden = true

        guard !query.isEmpty else {
            queue.addOperation { [weak self] in
                guard let self else { return }
                Task { @MainActor in
                    self.tracks = self.allTracks
                }
            }
            return
        }

        isLoading = true

        queue.addOperation(
            SearchOperation(query: query, allTracks: allTracks) { [weak self] in
                guard let self else { return }
                tracks = $0
                isNotFoundTextHidden = !$0.isEmpty
                isLoading = false
            }
        )
    }
}
