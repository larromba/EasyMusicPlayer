@testable import EasyMusicPlayer
import MediaPlayer
import Testing

@MainActor
struct ControlsViewModelTests {
    // MARK: - play

    @Test
    func play_givenIsPlaying_whenInvoked_expectNoSoundEffect() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(isPlaying: true)))

        env.sut.play()

        #expect(env.soundEffects.playCallCount == 0)
    }

    @Test
    func play_givenIsPlaying_whenInvoked_expectSoundEffect_andTogglePlayPause() {
        let env = setup()
        var soundEffect: SoundEffect?
        env.soundEffects.playHandler = { soundEffect = $0 }

        env.sut.play()

        #expect(env.soundEffects.playCallCount == 1)
        #expect(env.musicPlayer.togglePlayPauseCallCount == 1)
        #expect(soundEffect == .play)
    }

    // MARK: - stop

    @Test
    func stop_whenInvoked_expectSoundEffect_andStop() {
        let env = setup()
        var soundEffect: SoundEffect?
        env.soundEffects.playHandler = { soundEffect = $0 }

        env.sut.stop()

        #expect(env.soundEffects.playCallCount == 1)
        #expect(env.musicPlayer.stopCallCount == 1)
        #expect(soundEffect == .stop)
    }

    // MARK: - previous

    @Test
    func previous_givenIsDisabled_whenInvoked_expectNothing() {
        let env = setup()
        env.sut.previousButton.isDisabled = true

        env.sut.previous()

        #expect(env.soundEffects.playCallCount == 0)
        #expect(env.musicPlayer.previousCallCount == 0)
    }

    @Test
    func previous_givenIsEnabled_whenInvoked_expectSoundEffect_andStop() {
        let env = setup()
        var soundEffect: SoundEffect?
        env.soundEffects.playHandler = { soundEffect = $0 }
        env.sut.previousButton.isDisabled = false

        env.sut.previous()

        #expect(env.soundEffects.playCallCount == 1)
        #expect(env.musicPlayer.previousCallCount == 1)
        #expect(soundEffect == .prev)
    }

    // MARK: - next

    @Test
    func next_givenIsDisabled_whenInvoked_expectNothing() {
        let env = setup()
        env.sut.nextButton.isDisabled = true

        env.sut.next()

        #expect(env.soundEffects.playCallCount == 0)
        #expect(env.musicPlayer.previousCallCount == 0)
    }

    @Test
    func next_givenIsEnabled_whenInvoked_expectSoundEffect_andStop() {
        let env = setup()
        var soundEffect: SoundEffect?
        env.soundEffects.playHandler = { soundEffect = $0 }
        env.sut.nextButton.isDisabled = false

        env.sut.next()

        #expect(env.soundEffects.playCallCount == 1)
        #expect(env.musicPlayer.nextCallCount == 1)
        #expect(soundEffect == .next)
    }

    // MARK: - search

    @Test
    func search_whenInvoked_expectSoundEffect_andSearch() {
        var didSearch = false
        let env = setup { didSearch = true }
        var soundEffect: SoundEffect?
        env.soundEffects.playHandler = { soundEffect = $0 }

        env.sut.search()

        #expect(didSearch)
        #expect(env.soundEffects.playCallCount == 1)
        #expect(soundEffect == .search)
    }

    // MARK: - shuffle

    @Test
    func shuffle_whenInvoked_expectSoundEffect_andShuffle() {
        let env = setup()
        var soundEffect: SoundEffect?
        env.soundEffects.playHandler = { soundEffect = $0 }

        env.sut.shuffle()

        #expect(env.soundEffects.playCallCount == 1)
        #expect(env.musicPlayer.shuffleCallCount == 1)
        #expect(soundEffect == .shuffle)
    }

    // MARK: - toggleRepeatMode

    @Test
    func toggleRepeatMode_whenInvoked_expectSoundEffect_andToggleRepeatMode() {
        let env = setup()
        var soundEffect: SoundEffect?
        env.soundEffects.playHandler = { soundEffect = $0 }

        env.sut.toggleRepeatMode()

        #expect(env.soundEffects.playCallCount == 1)
        #expect(env.musicPlayer.toggleRepeatModeCallCount == 1)
        #expect(soundEffect == .repeat)
    }

    // MARK: - toggleLofi

    @Test
    func toggleLofi_whenInvoked_expectLofiToggled() {
        let env = setup()

        env.sut.toggleLofi()

        #expect(env.musicPlayer.toggleLofiCallCount == 1)
    }

    // MARK: - toggleDistortion

    @Test
    func toggleDistortion_whenInvoked_expectLofiToggled() {
        let env = setup()

        env.sut.toggleDistortion()

        #expect(env.musicPlayer.toggleDistortionCallCount == 1)
    }

    // MARK: - startSeeking

    @Test
    func startSeeking_whenInvoked_expectSoundEffect_andStartSeeking() {
        let env = setup()

        env.sut.startSeeking(.forward)

        #expect(env.musicPlayer.startSeekingCallCount == 1)
    }

    // MARK: - stopSeeking

    @Test
    func stopSeeking_whenInvoked_expectSoundEffect_andStartSeeking() {
        let env = setup()

        env.sut.stopSeeking()

        #expect(env.musicPlayer.stopSeekingCallCount == 1)
    }

    // MARK: - state 
    // MARK: prev buttons

    @Test(arguments: [MusicPlayerState.play, .pause, .stop, .reset, .repeatMode(.one)])
    func state_whenReceived_expectPrevButtonUpdated(for state: MusicPlayerState) {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(repeatMode: .one)))

        env.musicPlayer.stateSubject.send(state)

        #expect(!env.sut.previousButton.isDisabled, "\(state)")
        #expect(env.remote.previousTrackCommand.isEnabled, "\(state)")
    }

    @Test(arguments: [MusicPlayerState.play, .pause, .stop, .reset, .repeatMode(.none)])
    func state_givenNoRepeatMode_andIndexMax_whenReceived_expectPrevButtonUpdated(for state: MusicPlayerState) {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(index: 5, repeatMode: .none)))

        env.musicPlayer.stateSubject.send(state)

        #expect(!env.sut.previousButton.isDisabled, "\(state)")
        #expect(env.remote.previousTrackCommand.isEnabled, "\(state)")
    }

    @Test(arguments: [MusicPlayerState.play, .pause, .stop, .reset, .repeatMode(.none)])
    func state_givenNoRepeatMode_andIndexMin_whenReceived_expectPrevButtonUpdated(for state: MusicPlayerState) {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(index: 0, repeatMode: .none)))

        env.musicPlayer.stateSubject.send(state)

        #expect(env.sut.previousButton.isDisabled, "\(state)")
        #expect(!env.remote.previousTrackCommand.isEnabled, "\(state)")
    }

    // MARK: next buttons

    @Test(arguments: [MusicPlayerState.play, .pause, .stop, .reset, .repeatMode(.one)])
    func state_whenReceived_expectNextButtonUpdated(for state: MusicPlayerState) {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(repeatMode: .one)))

        env.musicPlayer.stateSubject.send(state)

        #expect(!env.sut.nextButton.isDisabled, "\(state)")
        #expect(env.remote.nextTrackCommand.isEnabled, "\(state)")
    }

    @Test(arguments: [MusicPlayerState.play, .pause, .stop, .reset, .repeatMode(.none)])
    func state_givenNoRepeatMode_andIndexMax_whenReceived_expectNextButtonUpdated(for state: MusicPlayerState) {
        let tracks = Array(repeating: MediaItemMock(), count: 5)
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(index: 4, tracks: tracks, repeatMode: .none)))

        env.musicPlayer.stateSubject.send(state)

        #expect(env.sut.nextButton.isDisabled, "\(state)")
        #expect(!env.remote.nextTrackCommand.isEnabled, "\(state)")
    }

    @Test(arguments: [MusicPlayerState.play, .pause, .stop, .reset, .repeatMode(.none)])
    func state_givenNoRepeatMode_andIndexMin_whenReceived_expectNextButtonUpdated(for state: MusicPlayerState) {
        let tracks = Array(repeating: MediaItemMock(), count: 5)
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(index: 0, tracks: tracks, repeatMode: .none)))

        env.musicPlayer.stateSubject.send(state)

        #expect(!env.sut.nextButton.isDisabled, "\(state)")
        #expect(env.remote.nextTrackCommand.isEnabled, "\(state)")
    }

    // MARK: play

    @Test
    func state_whenPlayReceived_expectUpdates() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.sut.playButton.image == .pauseButton)
        #expect(!env.sut.stopButton.isDisabled)
        #expect(env.remote.stopCommand.isEnabled)
    }

    // MARK: pause

    @Test
    func state_whenPauseReceived_expectUpdates() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.pause)

        #expect(env.sut.playButton.image == .playButton)
        #expect(!env.sut.stopButton.isDisabled)
        #expect(env.remote.stopCommand.isEnabled)
    }

    // MARK: stop

    @Test
    func state_whenStopReceived_expectUpdates() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.stop)

        #expect(env.sut.playButton.image == .playButton)
        #expect(env.sut.stopButton.isDisabled)
        #expect(!env.remote.stopCommand.isEnabled)
    }

    @Test
    func state_whenResetReceived_expectUpdates() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.reset)

        #expect(env.sut.playButton.image == .playButton)
        #expect(env.sut.stopButton.isDisabled)
        #expect(!env.remote.stopCommand.isEnabled)
    }

    // MARK: repeatMode

    struct RepeatModeTestData {
        let mode: RepeatMode
        let image: UIImage
    }

    @Test(arguments: [
        RepeatModeTestData(mode: .all, image: .repeatAllButton),
        RepeatModeTestData(mode: .one, image: .repeatOneButton),
        RepeatModeTestData(mode: .none, image: .repeatButton)
    ])
    func state_whenRepeatModeReceived_expectUpdates(for data: RepeatModeTestData) {
        let env = setup()

        env.musicPlayer.stateSubject.send(.repeatMode(data.mode))

        #expect(env.sut.repeatButton.image == data.image, "image: \(data.mode)")
        #expect(env.remote.changeRepeatModeCommand.currentRepeatType == data.mode.remote, "remote: \(data.mode)")
    }

    // MARK: search buton

    @Test(arguments: [MusicPlayerState.play, .pause, .stop, .repeatMode(.none)])
    func state_givenTracks_whenReceived_expectSearchButtonIsEnabled(for state: MusicPlayerState) {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: [.mock()])))

        env.musicPlayer.stateSubject.send(state)

        #expect(!env.sut.searchButton.isDisabled, "\(state)")
    }

    @Test(arguments: [MusicPlayerState.play, .pause, .stop, .repeatMode(.none)])
    func state_givenNoTracks_whenReceived_expectSearchButtonIsDisabled(for state: MusicPlayerState) {
        let env = setup()

        env.musicPlayer.stateSubject.send(state)

        #expect(env.sut.searchButton.isDisabled, "\(state)")
    }

    // MARK: - loaded

    @Test
    func state_givenTracks_whenLoadedReceived_expectSearchButtonIsEnabled() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: [.mock()])))

        env.musicPlayer.stateSubject.send(.loaded)

        #expect(!env.sut.searchButton.isDisabled)
    }

    @Test
    func state_givenNoTracks_whenLoadedReceived_expectSearchButtonIsDisabled() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.loaded)

        #expect(env.sut.searchButton.isDisabled)
    }

    // MARK: - lofi

    func state_whenLofiReceived_expectLofiIsDisabled() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.lofi(false))

        #expect(env.sut.lofiButton.isDisabled)
    }

    func state_whenLofiReceived_expectLofiIsEnabled() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.lofi(true))

        #expect(!env.sut.lofiButton.isDisabled)
    }

    // MARK: - distortion

    func state_whenDistortionReceived_expectLofiIsDisabled() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.distortion(false))

        #expect(env.sut.distortionButton.isDisabled)
    }

    func state_whenDistortionReceived_expectLofiIsEnabled() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.distortion(true))

        #expect(!env.sut.distortionButton.isDisabled)
    }

    private func setup(
        musicPlayer: MusicPlayableMock = MusicPlayableMock(info: .mock()),
        soundEffects: SoundEffectingMock = SoundEffectingMock(),
        remote: MPRemoteCommandCenter = MPRemoteCommandCenter.shared(),
        searchAction: @escaping () -> Void = {}
    ) -> Environmemnt {
        Environmemnt(
            musicPlayer: musicPlayer,
            soundEffects: soundEffects,
            remote: remote,
            sut: ControlsViewModel(
                musicPlayer: musicPlayer,
                remote: remote,
                soundEffects: soundEffects,
                searchAction: searchAction
            )
        )
    }
}

private extension ControlsViewModelTests {
    struct Environmemnt {
        let musicPlayer: MusicPlayableMock
        let soundEffects: SoundEffectingMock
        let remote: MPRemoteCommandCenter
        let sut: ControlsViewModel
    }
}
