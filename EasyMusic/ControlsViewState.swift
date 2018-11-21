import Foundation

struct ControlsViewState {
    let playButton: PlayButtonViewState
    let stopButton: GenericButtonViewState
    let prevButton: GenericButtonViewState
    let nextButton: GenericButtonViewState
    let shuffleButton: GenericButtonViewState
    let shareButton: GenericButtonViewState
    let repeatButton: RepeatButtonViewState
}

extension ControlsViewState {
    func copy(playButton: PlayButtonViewState) -> ControlsViewState {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            shareButton: shareButton,
            repeatButton: repeatButton
        )
    }

    func copy(stopButton: GenericButtonViewState) -> ControlsViewState {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            shareButton: shareButton,
            repeatButton: repeatButton
        )
    }

    func copy(prevButton: GenericButtonViewState) -> ControlsViewState {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            shareButton: shareButton,
            repeatButton: repeatButton
        )
    }

    func copy(nextButton: GenericButtonViewState) -> ControlsViewState {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            shareButton: shareButton,
            repeatButton: repeatButton
        )
    }

    func copy(shuffleButton: GenericButtonViewState) -> ControlsViewState {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            shareButton: shareButton,
            repeatButton: repeatButton
        )
    }

    func copy(shareButton: GenericButtonViewState) -> ControlsViewState {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            shareButton: shareButton,
            repeatButton: repeatButton
        )
    }

    func copy(repeatButton: RepeatButtonViewState) -> ControlsViewState {
        return ControlsViewState(
            playButton: playButton,
            stopButton: stopButton,
            prevButton: prevButton,
            nextButton: nextButton,
            shuffleButton: shuffleButton,
            shareButton: shareButton,
            repeatButton: repeatButton
        )
    }
}
