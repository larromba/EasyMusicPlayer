import Foundation

protocol ControlsViewStating {
    var playButton: PlayButtonViewStating { get }
    var stopButton: GenericButtonViewStating { get }
    var prevButton: GenericButtonViewStating { get }
    var nextButton: GenericButtonViewStating { get }
    var shuffleButton: GenericButtonViewStating { get }
    var repeatButton: RepeatButtonViewStating { get }

    func copy(playButton: PlayButtonViewStating) -> ControlsViewStating
    func copy(stopButton: GenericButtonViewStating) -> ControlsViewStating
    func copy(prevButton: GenericButtonViewStating) -> ControlsViewStating
    func copy(nextButton: GenericButtonViewStating) -> ControlsViewStating
    func copy(shuffleButton: GenericButtonViewStating) -> ControlsViewStating
    func copy(repeatButton: RepeatButtonViewStating) -> ControlsViewStating
}

struct ControlsViewState: ControlsViewStating {
    let playButton: PlayButtonViewStating
    let stopButton: GenericButtonViewStating
    let prevButton: GenericButtonViewStating
    let nextButton: GenericButtonViewStating
    let shuffleButton: GenericButtonViewStating
    let repeatButton: RepeatButtonViewStating
}

extension ControlsViewState {
    func copy(playButton: PlayButtonViewStating) -> ControlsViewStating {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            repeatButton: repeatButton
        )
    }

    func copy(stopButton: GenericButtonViewStating) -> ControlsViewStating {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            repeatButton: repeatButton
        )
    }

    func copy(prevButton: GenericButtonViewStating) -> ControlsViewStating {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            repeatButton: repeatButton
        )
    }

    func copy(nextButton: GenericButtonViewStating) -> ControlsViewStating {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            repeatButton: repeatButton
        )
    }

    func copy(shuffleButton: GenericButtonViewStating) -> ControlsViewStating {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            repeatButton: repeatButton
        )
    }

    func copy(repeatButton: RepeatButtonViewStating) -> ControlsViewStating {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            repeatButton: repeatButton
        )
    }
}
