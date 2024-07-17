@testable import EasyMusicPlayer
import MediaPlayer
import XCTest

@MainActor
final class ControlsViewModelTests: XCTestCase {
    private var musicPlayer: MusicPlayableMock!
    private var soundEffects: SoundEffectingMock!
    private var remote: MPRemoteCommandCenter!
    private var sut: ControlsViewModel!

    override func setUpWithError() throws {
        setup()
    }

    override func tearDownWithError() throws {
        musicPlayer = nil
        soundEffects = nil
        remote = nil
        sut = nil
    }

    // MARK: - play

    func test_play_givenIsPlaying_whenInvoked_expectNoSoundEffect() {
        setup(musicPlayer: MusicPlayableMock(info: .mock(isPlaying: true)))
        
        sut.play()

        XCTAssertEqual(soundEffects.playCallCount, 0)
    }

    func test_play_givenIsPlaying_whenInvoked_expectSoundEffect_andTogglePlayPause() {
        sut.play()

        soundEffects.playHandler = { XCTAssertEqual($0, .play) }
        XCTAssertEqual(soundEffects.playCallCount, 1)
        XCTAssertEqual(musicPlayer.togglePlayPauseCallCount, 1)
    }

    // MARK: - stop

    func test_stop_whenInvoked_expectSoundEffect_andStop() {
        sut.stop()

        soundEffects.playHandler = { XCTAssertEqual($0, .stop) }
        XCTAssertEqual(soundEffects.playCallCount, 1)
        XCTAssertEqual(musicPlayer.stopCallCount, 1)
    }

    // MARK: - previous

    func test_previous_givenIsDisabled_whenInvoked_expectNothing() {
        sut.previousButton.isDisabled = true

        sut.previous()

        XCTAssertEqual(soundEffects.playCallCount, 0)
        XCTAssertEqual(musicPlayer.previousCallCount, 0)
    }

    func test_previous_givenIsEnabled_whenInvoked_expectSoundEffect_andStop() {
        sut.previousButton.isDisabled = false

        sut.previous()

        soundEffects.playHandler = { XCTAssertEqual($0, .prev) }
        XCTAssertEqual(soundEffects.playCallCount, 1)
        XCTAssertEqual(musicPlayer.previousCallCount, 1)
    }

    // MARK: - next

    func test_next_givenIsDisabled_whenInvoked_expectNothing() {
        sut.previousButton.isDisabled = true

        sut.previous()

        XCTAssertEqual(soundEffects.playCallCount, 0)
        XCTAssertEqual(musicPlayer.previousCallCount, 0)
    }

    func test_next_givenIsEnabled_whenInvoked_expectSoundEffect_andStop() {
        sut.nextButton.isDisabled = false

        sut.next()

        soundEffects.playHandler = { XCTAssertEqual($0, .next) }
        XCTAssertEqual(soundEffects.playCallCount, 1)
        XCTAssertEqual(musicPlayer.nextCallCount, 1)
    }

    // MARK: - search

    func test_search_whenInvoked_expectSoundEffect_andSearch() {
        let expetation = expectation(description: "searchAction invoked")
        setup { expetation.fulfill() }

        sut.search()

        soundEffects.playHandler = { XCTAssertEqual($0, .search) }
        XCTAssertEqual(soundEffects.playCallCount, 1)
        waitForExpectations(timeout: 1)
    }

    // MARK: - shuffle

    func test_shuffle_whenInvoked_expectSoundEffect_andShuffle() {
        sut.shuffle()

        soundEffects.playHandler = { XCTAssertEqual($0, .shuffle) }
        XCTAssertEqual(soundEffects.playCallCount, 1)
        XCTAssertEqual(musicPlayer.shuffleCallCount, 1)
    }

    // MARK: - repeatMode

    func test_toggleRepeatMode_whenInvoked_expectSoundEffect_andToggleRepeatMode() {
        sut.toggleRepeatMode()

        soundEffects.playHandler = { XCTAssertEqual($0, .toggle) }
        XCTAssertEqual(soundEffects.playCallCount, 1)
        XCTAssertEqual(musicPlayer.toggleRepeatModeCallCount, 1)
    }
    
    // MARK: - startSeeking

    func test_startSeeking_whenInvoked_expectSoundEffect_andStartSeeking() {
        sut.startSeeking(.forward)

        XCTAssertEqual(musicPlayer.startSeekingCallCount, 1)
    }

    // MARK: - stopSeeking

    func test_stopSeeking_whenInvoked_expectSoundEffect_andStartSeeking() {
        sut.stopSeeking()

        XCTAssertEqual(musicPlayer.stopSeekingCallCount, 1)
    }

    // MARK: - state 
    // MARK: prev buttons

    func test_state_whenInvoked_expectPrevButtonUpdated() {
        setup(musicPlayer: MusicPlayableMock(info: .mock(repeatMode: .one)))
        let states: [MusicPlayerState] = [.play, .pause, .stop, .reset, .repeatMode(.one)]

        states.forEach {
            musicPlayer.stateSubject.send($0)

            XCTAssertFalse(sut.previousButton.isDisabled, "\($0)")
            XCTAssertTrue(remote.previousTrackCommand.isEnabled, "\($0)")
        }
    }

    func test_state_givenNoRepeatMode_andIndexGT0_whenInvoked_expectPrevButtonUpdated() {
        setup(musicPlayer: MusicPlayableMock(info: .mock(index: 5, repeatMode: .none)))
        let states: [MusicPlayerState] = [.play, .pause, .stop, .reset, .repeatMode(.none)]

        states.forEach {
            musicPlayer.stateSubject.send($0)

            XCTAssertFalse(sut.previousButton.isDisabled, "\($0)")
            XCTAssertTrue(remote.previousTrackCommand.isEnabled, "\($0)")
        }
    }

    func test_state_givenNoRepeatMode_andIndexLT0_whenInvoked_expectPrevButtonUpdated() {
        setup(musicPlayer: MusicPlayableMock(info: .mock(index: 0, repeatMode: .none)))
        let states: [MusicPlayerState] = [.play, .pause, .stop, .reset, .repeatMode(.none)]

        states.forEach {
            musicPlayer.stateSubject.send($0)

            XCTAssertTrue(sut.previousButton.isDisabled, "\($0)")
            XCTAssertFalse(remote.previousTrackCommand.isEnabled, "\($0)")
        }
    }

    // MARK: next buttons

    func test_state_whenInvoked_expectNextButtonUpdated() {
        setup(musicPlayer: MusicPlayableMock(info: .mock(repeatMode: .one)))
        let states: [MusicPlayerState] = [.play, .pause, .stop, .reset, .repeatMode(.one)]

        states.forEach {
            musicPlayer.stateSubject.send($0)

            XCTAssertFalse(sut.nextButton.isDisabled, "\($0)")
            XCTAssertTrue(remote.nextTrackCommand.isEnabled, "\($0)")
        }
    }

    func test_state_givenNoRepeatMode_andIndexGTEAll_whenInvoked_expectPrevButtonUpdated() {
        let tracks = Array(repeating: MediaItemMock(), count: 5)
        setup(musicPlayer: MusicPlayableMock(info: .mock(index: 4, tracks: tracks, repeatMode: .none)))
        let states: [MusicPlayerState] = [.play, .pause, .stop, .reset, .repeatMode(.none)]

        states.forEach {
            musicPlayer.stateSubject.send($0)

            XCTAssertTrue(sut.nextButton.isDisabled, "\($0)")
            XCTAssertFalse(remote.nextTrackCommand.isEnabled, "\($0)")
        }
    }

    func test_state_givenNoRepeatMode_andIndexLTAll_whenInvoked_expectPrevButtonUpdated() {
        let tracks = Array(repeating: MediaItemMock(), count: 5)
        setup(musicPlayer: MusicPlayableMock(info: .mock(index: 0, tracks: tracks, repeatMode: .none)))
        let states: [MusicPlayerState] = [.play, .pause, .stop, .reset, .repeatMode(.none)]

        states.forEach {
            musicPlayer.stateSubject.send($0)

            XCTAssertFalse(sut.nextButton.isDisabled, "\($0)")
            XCTAssertTrue(remote.nextTrackCommand.isEnabled, "\($0)")
        }
    }

    // MARK: play

    func test_state_whenPlayReceived_expectUpdates() {
        musicPlayer.stateSubject.send(.play)

        XCTAssertEqual(sut.playButton.image, .pauseButton)
        XCTAssertFalse(sut.stopButton.isDisabled)
        XCTAssertTrue(remote.stopCommand.isEnabled)
    }

    // MARK: pause

    func test_state_whenPauseReceived_expectUpdates() {
        musicPlayer.stateSubject.send(.pause)

        XCTAssertEqual(sut.playButton.image, .playButton)
        XCTAssertFalse(sut.stopButton.isDisabled)
        XCTAssertTrue(remote.stopCommand.isEnabled)
    }

    // MARK: stop

    func test_state_whenStopReceived_expectUpdates() {
        musicPlayer.stateSubject.send(.stop)

        XCTAssertEqual(sut.playButton.image, .playButton)
        XCTAssertTrue(sut.stopButton.isDisabled)
        XCTAssertFalse(remote.stopCommand.isEnabled)
    }

    func test_state_whenResetReceived_expectUpdates() {
        musicPlayer.stateSubject.send(.reset)

        XCTAssertEqual(sut.playButton.image, .playButton)
        XCTAssertTrue(sut.stopButton.isDisabled)
        XCTAssertFalse(remote.stopCommand.isEnabled)
    }

    // MARK: repeatMode

    func test_state_whenRepeatModeReceived_expectUpdates() {
        struct TestData {
            let mode: RepeatMode
            let image: UIImage
        }
        let testData = [
            TestData(mode: .all, image: .repeatAllButton),
            TestData(mode: .one, image: .repeatOneButton),
            TestData(mode: .none, image: .repeatButton)
        ]

        testData.forEach {
            musicPlayer.stateSubject.send(.repeatMode($0.mode))

            XCTAssertEqual(sut.repeatButton.image, $0.image, "image: \($0.mode)")
            XCTAssertEqual(remote.changeRepeatModeCommand.currentRepeatType, $0.mode.remote, "remote: \($0.mode)")
        }
    }

    // MARK: search buton

    func test_state_givenTracks_whenInvoked_expectSearchButtonIsEnabled() {
        let states: [MusicPlayerState] = [.play, .pause, .stop, .repeatMode(.none)]
        setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: [.mock()])))

        states.forEach {
            musicPlayer.stateSubject.send($0)

            XCTAssertFalse(sut.searchButton.isDisabled, "\($0)")
        }
    }

    func test_state_givenTracks_whenInvoked_expectSearchButtonIsDisabled() {
        let states: [MusicPlayerState] = [.play, .pause, .stop, .repeatMode(.none)]

        states.forEach {
            musicPlayer.stateSubject.send($0)

            XCTAssertTrue(sut.searchButton.isDisabled, "\($0)")
        }
    }

    private func setup(
        musicPlayer: MusicPlayableMock = MusicPlayableMock(info: .mock()),
        soundEffects: SoundEffectingMock = SoundEffectingMock(),
        remote: MPRemoteCommandCenter = MPRemoteCommandCenter.shared(),
        searchAction: @escaping () -> Void = {}
    ) {
        self.musicPlayer = musicPlayer
        self.soundEffects = soundEffects
        self.remote = remote
        sut = ControlsViewModel(
            musicPlayer: musicPlayer, 
            remote: remote,
            soundEffects: soundEffects,
            searchAction: searchAction
        )
    }
}
