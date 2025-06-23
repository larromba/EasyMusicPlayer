@testable import EasyMusicPlayer
import MediaPlayer
import Testing

@MainActor
@Suite(.serialized)
struct ScrubberViewModelTests: Waitable {
    private let musicPlayer: MusicPlayableMock
    private let sut: ScrubberViewModel

    init() {
        musicPlayer = MusicPlayableMock(info: .mock(track: .mock(playbackDuration: 60)))
        sut = ScrubberViewModel(musicPlayer: musicPlayer)
        sut.maxWidth = 100
    }

    // MARK: - state

    @Test
    func state_whenPlayReceived_expectIsEnabled() {
        musicPlayer.stateSubject.send(.play)

        #expect(!sut.isDisabled)
        #expect(sut.opacity == 0.5)
    }

    @Test
    func state_whenPauseReceived_expectIsDisabled() {
        musicPlayer.stateSubject.send(.pause)

        #expect(sut.isDisabled)
        #expect(sut.opacity == 0.2)
    }

    @Test
    func state_whenStopReceived_expectReset() {
        musicPlayer.stateSubject.send(.stop)

        #expect(sut.isDisabled)
        #expect(sut.opacity == 0.2)
        #expect(sut.width == 0)
    }

    @Test
    func state_givenDragging_whenClockReceived_expectReset() {
        musicPlayer.stateSubject.send(.clock(30))

        #expect(sut.width == 50)
    }

    @Test
    func state_givenNotDragging_whenClockReceived_expectNoChange() {
        sut.updateDrag(DragGestureValueMock())

        musicPlayer.stateSubject.send(.clock(30))

        #expect(sut.width == 0)
    }

    // MARK: - updateDrag

    @Test
    func updateDrag_whenInvoked_expectWidth() {
        sut.updateDrag(DragGestureValueMock(startLocation: .zero, translation: CGSize(width: 50, height: 0)))

        #expect(sut.width == 50)
    }

    @Test
    func updateDrag_whenInvoked_expectNoGreaterThanMaxWidth() {
        sut.updateDrag(DragGestureValueMock(startLocation: .zero, translation: CGSize(width: 200, height: 0)))

        #expect(sut.width == 100)
    }

    @Test
    func updateDrag_whenInvoked_expectNoLessThan0() {
        sut.updateDrag(DragGestureValueMock(startLocation: .zero, translation: CGSize(width: -200, height: 0)))

        #expect(sut.width == 0)
    }

    @Test
    func updateDrag_whenInvoked_expectMusicPlayerClockUpdated() {
        var time: TimeInterval?
        var isScrubbing: Bool?
        musicPlayer.setClockHandler = { time = $0; isScrubbing = $1 }

        sut.updateDrag(DragGestureValueMock(startLocation: .zero, translation: CGSize(width: 50, height: 0)))

        #expect(musicPlayer.setClockCallCount == 1)
        #expect(time == 30)
        #expect(isScrubbing == true)
    }

    // MARK: - finishedDrag

    @Test
    func finishedDrag_givenNoVelocity_whenInvoked_expectSameWidth() {
        sut.width = 50

        sut.finishDrag(DragGestureValueMock(startLocation: CGPoint(x: 50, y: 0), velocity: .zero))

        #expect(sut.width == 50)
    }

    @Test
    func finishedDrag_givenHighPositiveVelocity_whenInvoked_expectNoGreaterThanMaxWidth() {
        sut.width = 99

        sut.finishDrag(DragGestureValueMock(velocity: CGSize(width: 1500, height: 0)))

        #expect(sut.width == 100)
    }

    @Test
    func finishedDrag_givenHighPositiveVelocity_whenInvoked_expectMaxChange() {
        sut.finishDrag(DragGestureValueMock(velocity: CGSize(width: 2000, height: 0)))

        #expect(sut.width == 5)
    }

    @Test
    func finishedDrag_givenHighNegativeVelocity_whenInvoked_expectMaxChange() {
        sut.width = 50

        sut.finishDrag(DragGestureValueMock(velocity: CGSize(width: -2000, height: 0)))

        #expect(sut.width == 45)
    }

    @Test
    func finishedDrag_whenInvoked_expectMusicPlayerClockUpdated() {
        sut.width = 50
        var time: TimeInterval?
        var isScrubbing: Bool?
        musicPlayer.setClockHandler = { time = $0; isScrubbing = $1 }

        sut.finishDrag(DragGestureValueMock())

        #expect(musicPlayer.setClockCallCount == 1)
        #expect(time == 30)
        #expect(isScrubbing == false)
    }
}
