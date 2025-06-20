import Combine
import SwiftUI

@MainActor
final class ScrubberViewModel: ObservableObject {
    @Published var width: CGFloat = 0
    @Published var maxWidth: CGFloat = 0
    @Published var opacity: CGFloat = 0
    @Published var isDisabled = true

    private let musicPlayer: MusicPlayable
    private var cancellables = [AnyCancellable]()
    private var isDragging = false {
        didSet { opacity = isDragging ? 0.4 : 0.5 }
    }

    init(musicPlayer: MusicPlayable) {
        self.musicPlayer = musicPlayer

        setupBindings()
    }

    func updateDrag(_ gesture: DragGestureValue) {
        isDragging = true
        let startPoint = gesture.startLocation
        let translation = gesture.translation
        width = min(maxWidth, max(startPoint.x + translation.width, 0))

        let duration = musicPlayer.info.trackInfo.duration
        guard duration > 0, maxWidth > 0 else { return }
        let percentage = width / maxWidth
        musicPlayer.setClock(duration * percentage, isScrubbing: true)
    }

    func finishDrag(_ gesture: DragGestureValue) {
        let absVelocity: Double = abs(gesture.velocity.width)
        var bounce = absVelocity.scale(rMin: 0, rMax: 1500, tMin: 0, tMax: 5) // scale velocity
        bounce = gesture.velocity.width < 0 ? (bounce * -1) : bounce // left is -, right is +
        width = min(maxWidth, max(width + bounce, 0))

        let duration = musicPlayer.info.trackInfo.duration
        guard duration > 0, maxWidth > 0 else { return }
        let percentage = width / maxWidth
        musicPlayer.setClock(duration * percentage, isScrubbing: false)
        isDragging = false
    }

    private func setupBindings() {
        musicPlayer.state.sink { [weak self] in
            guard let self else { return }
            switch $0 {
            case .play:
                opacity = 0.5
                isDisabled = false
            case .pause:
                opacity = 0.2
                isDisabled = true
            case .stop:
                opacity = 0.2
                width = 0
                isDisabled = true
            case .clock(let timeInterval):
                updateClock(timeInterval)
            default:
                break
            }
        }.store(in: &cancellables)
    }

    private func updateClock(_ timeInterval: TimeInterval) {
        guard !isDragging else { return }
        let duration = musicPlayer.info.trackInfo.duration
        guard duration > 0 else {
            width = 0
            return
        }
        let percentage = timeInterval / duration
        width = maxWidth * percentage
    }
}

private extension Double {
    // see: https://stats.stackexchange.com/questions/281162/scale-a-number-between-a-range
    // `m` == `self`
    func scale(rMin: Double, rMax: Double, tMin: Double, tMax: Double) -> Double {
        let value = ((self - rMin) / (rMax - rMin)) * (tMax - tMin) + tMin
        guard value >= tMin else { return tMin }
        guard value <= tMax else { return tMax }
        return value
    }
}
