@preconcurrency import AVFoundation
@preconcurrency import Combine
import Foundation
@preconcurrency import MediaPlayer

// switlint:disable type_body_length
/// see: `SimlatorMusicLibary` to change the library on the simulator
final class MusicPlayer: NSObject, MusicPlayable {
    var state: AnyPublisher<MusicPlayerState, Never> {
        statePublisher
            .share()
            .eraseToAnyPublisher()
    }
    var info: MusicPlayerInformation {
        let (currentTime, isPlaying) = audioPlayer.withValue {
            ($0?.currentTime ?? 0, $0?.isPlaying ?? false)
        }
        return MusicPlayerInformation(
            trackInfo: CurrentTrackInformation(
                track: queue.currentTrack,
                index: queue.currentTrackIndex
            ),
            tracks: queue.tracks,
            time: currentTime,
            isPlaying: isPlaying,
            repeatMode: queue.repeatMode
        )
    }

    // dependencies
    private let notificationCenter: NotificationCenter
    private let mediaLibrary: MPMediaLibrary
    private let audioClock: AudioClocking
    private let queue: MusicQueuable
    private let authorization: MusicAuthorizable
    private let interruptionHandler: MusicInterruptionHandling
    private let session: AVAudioSession
    private let remote: MPRemoteCommandCenter
    private let seeker: Seekable

    // local
    private let statePublisher = CurrentValueSubject<MusicPlayerState, Never>(.stop)
    private let audioPlayer = LockIsolated<AVAudioPlayer?>(nil)
    private let cancellables = LockIsolated<[AnyCancellable]>([])

    init(
        notificationCenter: NotificationCenter = .default,
        mediaLibrary: MPMediaLibrary = .default(),
        audioClock: AudioClocking = AudioClock(),
        queue: MusicQueuable = MusicQueue(),
        authorization: MusicAuthorizable = MusicAuthorization(),
        interruptionHandler: MusicInterruptionHandling = MusicInterruptionHandler(),
        session: AVAudioSession = .sharedInstance(),
        remote: MPRemoteCommandCenter = .shared(),
        seeker: Seeker = Seeker()
    ) {
        self.notificationCenter = notificationCenter
        self.mediaLibrary = mediaLibrary
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
        tearDownMediaLibraryDidChangeNotification()
    }

    func authorize() {
        authorization.authorize { [weak self] success in
            guard let self else { return }
            guard success else {
                statePublisher.send(.error(.auth))
                return
            }
            setupMediaLibraryDidChangeNotification()
            queue.load()
            statePublisher.send(.loaded)
        }
    }

    func play(_ track: MPMediaItem) {
        stop()
        queue.prime(track)
        play()
    }

    func play(_ position: MusicQueueTrackPosition = .current) {
        let shouldStart = audioPlayer.withValue { $0?.isPaused ?? false }
        if shouldStart {
            start()
            return
        }
        guard session.outputVolume > 0 else {
            statePublisher.send(.error(.volume))
            return
        }
        guard !queue.tracks.isEmpty else {
            statePublisher.send(.error(.noMusic))
            return
        }
        guard let current = queue.track(for: position) else {
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
            self.audioPlayer.setValue(audioPlayer)
            start()
        } catch {
            logError("play error: \(String(describing: error))")
            statePublisher.send(.error(.play))
        }
    }

    func pause() {
        seeker.stop()
        audioPlayer.withValue { $0?.pause() }
        audioClock.stop()
        statePublisher.send(.pause)
    }

    func togglePlayPause() {
        let isPlaying = audioPlayer.withValue { $0?.isPlaying ?? false }
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        seeker.stop()
        audioClock.stop()
        audioPlayer.withValue {
            $0?.delegate = nil
            $0?.stop()
        }
        audioPlayer.setValue(nil)
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
        audioPlayer.withValue { $0?.currentTime = timeInterval }
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
        do {
            try session.setCategory(.playback)
            try session.setActive(true)

            let didPlay = audioPlayer.withValue { $0?.play() ?? false }
            guard didPlay else {
                throw MusicPlayerError.play
            }

            audioClock.start()
            statePublisher.send(.play)

            let currentTime = audioPlayer.withValue { $0?.currentTime ?? 0 }
            statePublisher.send(.clock(currentTime))
        } catch {
            stop()
            logError("start error: \(String(describing: error))")
            statePublisher.send(.error(.play))
        }
    }

    private func setupMediaLibraryDidChangeNotification() {
        mediaLibrary.beginGeneratingLibraryChangeNotifications()

        notificationCenter.addObserver(
            forName: .MPMediaLibraryDidChange,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self, queue.hasUpdates() else { return }
            stop()
            queue.create()
            statePublisher.send(.reset)
        }
    }

    private func tearDownMediaLibraryDidChangeNotification() {
        mediaLibrary.endGeneratingLibraryChangeNotifications()

        notificationCenter.removeObserver(
            self,
            name: .MPMediaLibraryDidChange,
            object: nil
        )
    }

    private func setupInterruptionHandler() {
        cancellables.withValue {
            state.sink { [interruptionHandler] in
                switch $0 {
                case .play:
                    interruptionHandler.isPlaying = true
                case .pause, .stop:
                    interruptionHandler.isPlaying = false
                default:
                    break
                }
            }.store(in: &$0)
        }

        interruptionHandler.setCallback { [weak self] action in
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
        audioClock.setCallback { [weak self] in
            guard let self, let currentTime = audioPlayer.withValue({ $0?.currentTime }) else {
                return
            }
            statePublisher.send(.clock(currentTime))
        }
    }

    private func setupInitialState() {
        statePublisher.send(.stop)
        statePublisher.send(.repeatMode(queue.repeatMode))
    }

    private func setupSeeker() {
        seeker.setSeekCallback { [weak self] time in
            guard let self, let newTime = audioPlayer.withValue({ player -> TimeInterval? in
                guard let player else { return nil }
                return player.currentTime + time
            }) else { return }
            setClock(newTime > 0 ? newTime : 0)
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
