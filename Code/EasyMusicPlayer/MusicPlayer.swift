import AVFoundation
import Combine
import Foundation
import MediaPlayer

// switlint:disable type_body_length
/// see: `SimlatorMusicLibary` to change the library on the simulator
final class MusicPlayer: NSObject, MusicPlayable {
    var state: AnyPublisher<MusicPlayerState, Never> {
        statePublisher
            .share()
            .eraseToAnyPublisher()
    }
    var info: MusicPlayerInformation {
        MusicPlayerInformation(
            track: CurrentTrackInformation(
                item: queue.current,
                index: queue.index
            ),
            tracks: queue.items,
            time: audioPlayer?.currentTime ?? 0,
            isPlaying: audioPlayer?.isPlaying ?? false,
            repeatMode: queue.repeatMode
        )
    }

    // dependencies
    private let audioClock: AudioClocking
    private let queue: MusicQueuable
    private let authorization: MusicAuthorizable
    private let interruptionHandler: MusicInterruptionHandling
    private let session: AVAudioSession
    private let remote: MPRemoteCommandCenter
    private let seeker: Seekable

    // local
    private let statePublisher = CurrentValueSubject<MusicPlayerState, Never>(.stop)
    private var audioPlayer: AVAudioPlayer?
    private var cancellables = [AnyCancellable]()

    init(
        audioClock: AudioClocking = AudioClock(),
        queue: MusicQueuable = MusicQueue(),
        authorization: MusicAuthorizable = MusicAuthorization(),
        interruptionHandler: MusicInterruptionHandling = MusicInterruptionHandler(),
        session: AVAudioSession = .sharedInstance(),
        remote: MPRemoteCommandCenter = .shared(),
        seeker: Seeker = Seeker()
    ) {
        self.audioClock = audioClock
        self.queue = queue
        self.authorization = authorization
        self.interruptionHandler = interruptionHandler
        self.session = session
        self.seeker = seeker
        self.remote = remote

        super.init()

        setupInterruptionHandler()
        setupAudioClock()
        setupInitialState()
        setupRemote()
        setupSeeker()
    }

    deinit {
        tearDownRemote()
    }

    func authorize() {
        authorization.authorize { [weak self] success in
            guard let self else { return }
            guard success else {
                statePublisher.send(.error(.auth))
                return
            }
            queue.load()
        }
    }

    func play(_ track: MPMediaItem) {
        queue.prime(track)
        play()
    }

    func play(_ position: MusicQueueTrackPosition = .current) {
        if let audioPlayer, audioPlayer.isPaused {
            start()
            return
        }
        guard session.outputVolume > 0 else {
            statePublisher.send(.error(.volume))
            return
        }
        guard !queue.items.isEmpty else {
            statePublisher.send(.error(.noMusic))
            return
        }
        guard let current = queue.item(for: position) else {
            statePublisher.send(.error(.finished))
            return
        }
        guard let url = current.assetURL else {
            next()
            return
        }
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            self.audioPlayer = audioPlayer
            start()
        } catch {
            logError("play error: \(String(describing: error))")
            statePublisher.send(.error(.play))
            return
        }
    }

    func pause() {
        seeker.stop()
        audioPlayer?.pause()
        audioClock.stop()
        statePublisher.send(.pause)
    }

    func togglePlayPause() {
        if let audioPlayer, audioPlayer.isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        seeker.stop()
        audioPlayer?.stop()
        audioPlayer = nil
        audioClock.stop()
        statePublisher.send(.stop)
    }

    func previous() {
        stop()
        play(.previous)
    }

    func next() {
        stop()
        play(.next)
    }

    func shuffle() {
        stop()
        queue.create()
        play()
    }

    func toggleRepeatMode() {
        queue.toggleRepeatMode()
        statePublisher.send(.repeatMode(queue.repeatMode))
    }

    func setRepeatMode(_ repeatMode: RepeatMode) {
        queue.repeatMode = repeatMode
        statePublisher.send(.repeatMode(queue.repeatMode))
    }

    func setClock(_ timeInterval: TimeInterval, isScrubbing: Bool = false) {
        audioClock.stop()
        statePublisher.send(.clock(timeInterval))

        guard !isScrubbing else { return }
        audioPlayer?.currentTime = timeInterval
        audioClock.start()
    }

    func startSeeking(_ direction: SeekDirection) {
        guard info.isPlaying else { return }
        seeker.seek(direction)
    }

    func stopSeeking() {
        seeker.stop()
    }

    private func start() {
        guard let audioPlayer else { return }
        do {
            try session.setCategory(.playback)
            try session.setActive(true)
            guard audioPlayer.play() else {
                throw MusicPlayerError.play
            }
            audioClock.start()
            statePublisher.send(.play)
            statePublisher.send(.clock(audioPlayer.currentTime))
        } catch {
            stop()
            logError("start error: \(String(describing: error))")
            statePublisher.send(.error(.play))
        }
    }

    private func setupInterruptionHandler() {
        state.sink { [interruptionHandler] in
            switch $0 {
            case .play:
                interruptionHandler.isPlaying = true
            case .pause, .stop:
                interruptionHandler.isPlaying = false
            default:
                break
            }
        }.store(in: &cancellables)

        interruptionHandler.callback = { [weak self] action in
            guard let self else { return }
            switch action {
            case .pause:
                pause()
            case .play:
                play()
            }
        }
    }

    private func setupAudioClock() {
        audioClock.callback = { [weak self] in
            guard let self, let audioPlayer else { return }
            statePublisher.send(.clock(audioPlayer.currentTime))
        }
    }

    private func setupInitialState() {
        statePublisher.send(.stop)
        statePublisher.send(.repeatMode(queue.repeatMode))
    }

    private func setupSeeker() {
        seeker.seek = { [weak self] time in
            guard let self, let audioPlayer else { return }
            let time = audioPlayer.currentTime + time
            setClock(time > 0 ? time : 0)
        }
    }
}

// MARK: - Remote
// this could probably be tested by wrapping MPRemoteCommandCenter in a class, but it seems overkill.
// if you modify this code - please test it

extension MusicPlayer {
    // swiftlint:disable function_body_length cyclomatic_complexity
    private func setupRemote() {
        remote.togglePlayPauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            guard let self else { return .commandFailed }
            togglePlayPause()
            return .success
        }
        remote.pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            guard let self else { return .commandFailed }
            pause()
            return .success
        }
        remote.playCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            guard let self else { return .commandFailed }
            play()
            return .success
        }
        remote.stopCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            guard let self else { return .commandFailed }
            stop()
            return .success
        }
        remote.previousTrackCommand.addTarget { [weak self]  _ -> MPRemoteCommandHandlerStatus in
            guard let self else { return .commandFailed }
            previous()
            return .success
        }
        remote.nextTrackCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            guard let self else { return .commandFailed }
            next()
            return .success
        }
        remote.seekBackwardCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let self, let event = event as? MPSeekCommandEvent else { return .commandFailed }
            switch event.type {
            case .beginSeeking:
                startSeeking(.backward)
            case .endSeeking:
                stopSeeking()
            default:
                logError("unhandled \(MPSeekCommandEvent.self)")
            }
            return .success
        }
        remote.seekForwardCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let self, let event = event as? MPSeekCommandEvent else { return .commandFailed }
            switch event.type {
            case .beginSeeking:
                startSeeking(.forward)
            case .endSeeking:
                stopSeeking()
            default:
                logError("unhandled \(MPSeekCommandEvent.self)")
            }
            return .success
        }
        remote.changePlaybackPositionCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let self, let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            setClock(event.positionTime)
            return .success
        }
        remote.changeRepeatModeCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let self, let event = event as? MPChangeRepeatModeCommandEvent else { return .commandFailed }
            setRepeatMode(event.repeatType.repeatMode)
            return .success
        }
    }

    private func tearDownRemote() {
        remote.togglePlayPauseCommand.removeTarget(self)
        remote.pauseCommand.removeTarget(self)
        remote.playCommand.removeTarget(self)
        remote.previousTrackCommand.removeTarget(self)
        remote.nextTrackCommand.removeTarget(self)
        remote.seekForwardCommand.removeTarget(self)
        remote.seekBackwardCommand.removeTarget(self)
        remote.changePlaybackPositionCommand.removeTarget(self)
        remote.changeRepeatModeCommand.removeTarget(self)
    }
}

// MARK: - AVAudioPlayerDelegate

extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ service: AVAudioPlayer, successfully flag: Bool) {
        if !flag { logError("issue finishing track") }
        next()
    }

    func audioPlayerDecodeErrorDidOccur(_ service: AVAudioPlayer, error: Error?) {
        logError("decode error: \(String(describing: error))")
        next()
    }
}
