@testable import EasyMusicPlayer
import MediaPlayer
import XCTest

@MainActor
final class ScrubberViewModelTests: XCTestCase {
    private var musicPlayer: MusicPlayableMock!
    private var sut: ScrubberViewModel!

    override func setUpWithError() throws {
        musicPlayer = MusicPlayableMock(info: .mock(track: .mock(playbackDuration: 60)))
        sut = ScrubberViewModel(musicPlayer: musicPlayer)
        sut.maxWidth = 100
    }

    override func tearDownWithError() throws {
        musicPlayer = nil
        sut = nil
    }

    // MARK: - state

    func test_state_whenPlayReceived_expectIsEnabled() {
        musicPlayer.stateSubject.send(.play)

        XCTAssertFalse(sut.isDisabled)
        XCTAssertEqual(sut.opacity, 0.5)
    }

    func test_state_whenPauseReceived_expectIsDisabled() {
        musicPlayer.stateSubject.send(.pause)

        XCTAssertTrue(sut.isDisabled)
        XCTAssertEqual(sut.opacity, 0.2)
    }

    func test_state_whenStopReceived_expectReset() {
        musicPlayer.stateSubject.send(.stop)

        XCTAssertTrue(sut.isDisabled)
        XCTAssertEqual(sut.opacity, 0.2)
        XCTAssertEqual(sut.width, 0)
    }

    func test_state_givenDragging_whenClockReceived_expectReset() {
        musicPlayer.stateSubject.send(.clock(30))

        XCTAssertEqual(sut.width, 50)
    }

    func test_state_givenNotDragging_whenClockReceived_expectNoChange() {
        sut.updateDrag(DragGestureMock())

        musicPlayer.stateSubject.send(.clock(30))

        XCTAssertEqual(sut.width, 0)
    }

    // MARK: - updateDrag

    func test_updateDrag_whenInvoked_expectWidth() {
        sut.updateDrag(DragGestureMock(startLocation: .zero, translation: CGSize(width: 50, height: 0)))

        XCTAssertEqual(sut.width, 50)
    }

    func test_updateDrag_whenInvoked_expectNoGreaterThanMaxWidth() {
        sut.updateDrag(DragGestureMock(startLocation: .zero, translation: CGSize(width: 200, height: 0)))

        XCTAssertEqual(sut.width, 100)
    }

    func test_updateDrag_whenInvoked_expectNoLessThan0() {
        sut.updateDrag(DragGestureMock(startLocation: .zero, translation: CGSize(width: -200, height: 0)))

        XCTAssertEqual(sut.width, 0)
    }

    func test_updateDrag_whenInvoked_expectMusicPlayerClockUpdated() {
        musicPlayer.setClockHandler = { (time, isScrubbing) in
            XCTAssertEqual(time, 30)
            XCTAssertTrue(isScrubbing)
        }

        sut.updateDrag(DragGestureMock(startLocation: .zero, translation: CGSize(width: 50, height: 0)))

        XCTAssertEqual(musicPlayer.setClockCallCount, 1)
    }

    // MARK: - finishedDrag

    func test_finishedDrag_givenNoVelocity_whenInvoked_expectSameWidth() {
        sut.width = 50

        sut.finishDrag(DragGestureMock(startLocation: CGPoint(x: 50, y: 0), velocity: .zero))

        XCTAssertEqual(sut.width, 50)
    }

    func test_finishedDrag_givenHighPositiveVelocity_whenInvoked_expectNoGreaterThanMaxWidth() {
        sut.width = 99

        sut.finishDrag(DragGestureMock(velocity: CGSize(width: 1500, height: 0)))

        XCTAssertEqual(sut.width, 100)
    }

    func test_finishedDrag_givenHighPositiveVelocity_whenInvoked_expectMaxChange() {
        sut.finishDrag(DragGestureMock(velocity: CGSize(width: 2000, height: 0)))

        XCTAssertEqual(sut.width, 5)
    }

    func test_finishedDrag_givenHighNegativeVelocity_whenInvoked_expectMaxChange() {
        sut.width = 50

        sut.finishDrag(DragGestureMock(velocity: CGSize(width: -2000, height: 0)))

        XCTAssertEqual(sut.width, 45)
    }

    func test_finishedDrag_whenInvoked_expectMusicPlayerClockUpdated() {
        sut.width = 50
        musicPlayer.setClockHandler = { (time, isScrubbing) in
            XCTAssertEqual(time, 30)
            XCTAssertFalse(isScrubbing)
        }

        sut.finishDrag(DragGestureMock())

        XCTAssertEqual(musicPlayer.setClockCallCount, 1)
    }
}
