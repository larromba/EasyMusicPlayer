import Foundation
import Logging
import MediaPlayer

protocol MusicServiceDelegate: AnyObject {
    func musicService(_ service: MusicServicing, threwError error: MusicError)
    func musicService(_ service: MusicServicing, changedState state: PlayState)
    func musicService(_ service: MusicServicing, changedRepeatState state: RepeatState)
    func musicService(_ service: MusicServicing, changedPlaybackTime playbackTime: TimeInterval)
}

// sourcery: name = MusicService
protocol MusicServicing: AnyObject, Mockable {
    var state: MusicServiceState { get }

    func setDelegate(_ delegate: MusicServiceDelegate)
    func setRepeatState(_ repeatState: RepeatState)
    func setTime(_ time: TimeInterval)
    func prime(_ track: Track) -> Bool
    func play()
    func stop()
    func pause()
    func previous()
    func next()
    func shuffle()
    func skip()
}

// swiftlint:disable type_body_length
final class MusicService: NSObject, MusicServicing {
    private var player: AudioPlayer?
    private weak var delegate: MusicServiceDelegate?
    private let trackManager: TrackManaging
    private let remote: Remoting
    private let audioSession: AudioSession
    private let authorization: Authorization
    private let seeker: Seekable
    private let interruptionHandler: MusicInterruptionHandling
    private let clock: Clocking
    private var playState: PlayState = .stopped
    private var repeatState: RepeatState = .none
    private let playerFactory: AudioPlayerFactoring

    var state: MusicServiceState {
        return MusicServiceState(
            isPlaying: player?.isPlaying ?? false,
            volume: audioSession.outputVolume,
            currentTrackIndex: trackManager.currentTrackIndex,
            totalTracks: trackManager.totalTracks,
            currentTrack: trackManager.currentTrackResolved,
            time: player?.currentTime ?? 0.0,
            playState: playState,
            repeatState: repeatState
        )
    }

    init(trackManager: TrackManaging, remote: Remoting, audioSession: AudioSession,
         authorization: Authorization, seeker: Seekable, interruptionHandler: MusicInterruptionHandling,
         clock: Clocking, playerFactory: AudioPlayerFactoring) {
        self.trackManager = trackManager
        self.remote = remote
        self.audioSession = audioSession
        self.authorization = authorization
        self.seeker = seeker
        self.interruptionHandler = interruptionHandler
        self.clock = clock
        self.playerFactory = playerFactory
        super.init()
        seeker.setDelegate(self)
        interruptionHandler.setDelegate(self)
        clock.setDelegate(self)
        trackManager.setDelegate(self)
        setupNotifications()
        setupRemote()
        authorizeThenPerform({
            self.trackManager.loadSavedPlaylist()
            if self.trackManager.totalTracks == 0 {
                self.trackManager.loadNewPlaylist(shuffled: true)
            }
        })
    }

    deinit {
        cleanUp()
    }

    func setDelegate(_ delegate: MusicServiceDelegate) {
        self.delegate = delegate
    }

    func setRepeatState(_ repeatState: RepeatState) {
        self.repeatState = repeatState
    }

    func setTime(_ time: TimeInterval) {
        guard let player = player else { return }
        player.currentTime = time
        delegate?.musicService(self, changedPlaybackTime: time)
    }

    func prime(_ track: Track) -> Bool {
        return trackManager.prime(track)
    }

    func play() {
        authorizeThenPerform({
            guard self.trackManager.totalTracks > 0 else {
                self.throwError(.noMusic)
                return
            }
            guard self.state.volume > 0.0 else {
                self.throwError(.noVolume)
                return
            }
            guard let url = self.trackManager.currentTrackResolved.url else {
                self.throwError(.playerInit)
                return
            }

            if self.player?.url?.absoluteString != url.absoluteString {
                do {
                    let player = try self.playerFactory.makeAudioPlayer(withContentsOf: url)
                    player.delegate = self
                    self.player = player
                } catch {
                    logError(error.localizedDescription)
                    self.throwError(.playerInit)
                    return
                }
            }

            let enable = self.setAudioSessionIsEnabled(true)
            let prepare = self.player?.prepareToPlay() ?? false
            let play = self.player?.play() ?? false
            guard enable, prepare, play else {
                logError("enable: \(enable), prepare: \(prepare), play: \(play)")
                self.throwError(.avError)
                return
            }

            self.player?.updateDuration(self.trackManager.currentTrackResolved.duration)
            self.clock.start()
            self.interruptionHandler.setIsPlaying(true)
            self.changePlayState(.playing)
        })
    }

    func stop() {
        guard let player = player else { return }
        player.stop()
        self.player = nil

        clock.stop()
        seeker.stopSeeking()
        player.currentTime = 0.0

        interruptionHandler.setIsPlaying(false)
        changePlayState(.stopped)
    }

    func pause() {
        guard let player = player else { return }
        player.pause()

        clock.stop()
        seeker.stopSeeking()

        interruptionHandler.setIsPlaying(false)
        changePlayState(.paused)
    }

    func previous() {
        stop()

        let result = trackManager.cuePrevious()
        if repeatState == .all && !result {
            trackManager.cueEnd()
        }

        play()
    }

    func next() {
        stop()

        let result = trackManager.cueNext()
        if repeatState == .all && !result {
            trackManager.cueStart()
        }

        play()
    }

    func shuffle() {
        authorizeThenPerform({
            self.trackManager.loadNewPlaylist(shuffled: true)
        })
    }

    func skip() {
        trackManager.removeTrack(atIndex: trackManager.currentTrackIndex)
        next()
    }

    // MARK: - private

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillTerminate(_:)),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    private func setupRemote() {
        remote.togglePlayPause = { [weak self] in
            self?.togglePlayPause()
        }
        remote.pause = { [weak self] in
            self?.pause()
        }
        remote.play = { [weak self] in
            self?.play()
        }
        remote.stop = { [weak self] in
            self?.stop()
        }
        remote.prev = { [weak self] in
            self?.previous()
        }
        remote.next = { [weak self] in
            self?.next()
        }
        remote.seekBackward = { [weak self] event in
            self?.seekBackward(event)
        }
        remote.seekForward = { [weak self] event in
            self?.seekForward(event)
        }
        remote.changePlayback = { [weak self] event in
            self?.changePlaybackPosition(event)
        }
        remote.repeatMode = { [weak self] event in
            guard let self = self else { return }
            self.repeatState = event.repeatType.repeatState
            self.delegate?.musicService(self, changedRepeatState: event.repeatType.repeatState)
        }
    }

    private func setAudioSessionIsEnabled(_ isEnabled: Bool) -> Bool {
        do {
            if isEnabled {
                try audioSession.setCategory_objc(.playback, with: [])
            }
            try audioSession.setActive_objc(isEnabled, options: [])
        } catch {
            logError(error.localizedDescription)
            return false
        }
        return true
    }

    private func changePlayState(_ state: PlayState) {
        log(state)
        playState = state
        delegate?.musicService(self, changedState: state)
    }

    private func authorizeThenPerform(_ block: @escaping (() -> Void)) {
        authorization.authorize({ [weak self] (_ success: Bool) in
            guard success else {
                self?.throwError(.authorization)
                return
            }
            block()
        })
    }

    private func throwError(_ error: MusicError) {
        stop()
        delegate?.musicService(self, threwError: error)
    }

    private func cleanUp() {
        _ = setAudioSessionIsEnabled(false)
    }

    // MARK: - actions

    private func togglePlayPause() {
        if state.isPlaying {
            pause()
        } else {
            play()
        }
    }

    private func changePlaybackPosition(_ event: ChangePlaybackPositionCommandEvent) {
        player?.currentTime = event.positionTime
    }

    private func seekForward(_ event: SeekCommandEvent) {
        guard player != nil else { return }
        switch event.type {
        case .beginSeeking:
            seeker.startSeekingWithAction(.forward)
        case .endSeeking:
            seeker.stopSeeking()
        default:
            assertionFailure("unhandled SeekCommandEvent")
        }
    }

    private func seekBackward(_ event: SeekCommandEvent) {
        guard player != nil else { return }
        switch event.type {
        case .beginSeeking:
            seeker.startSeekingWithAction(.backward)
        case .endSeeking:
            seeker.stopSeeking()
        default:
            assertionFailure("unhandled SeekCommandEvent")
        }
    }

    // MARK: - notifications

    @objc
    private func applicationWillTerminate(_ notifcation: Notification) {
        cleanUp()
    }
}

// MARK: - AVAudioPlayerDelegate

extension MusicService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ service: AVAudioPlayer, successfully flag: Bool) {
        guard flag else {
            throwError(.avError)
            return
        }
        switch repeatState {
        case .one:
            play()
        case .none:
            guard !trackManager.isLastTrack else {
                stop()
                changePlayState(.finished)
                return
            }
            next()
        case .all:
            next()
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ service: AVAudioPlayer, error: Error?) {
        throwError(.decode)
    }
}

// MARK: - SeekerDelegate

extension MusicService: SeekerDelegate {
    func seeker(_ seeker: Seekable, updateDelta: TimeInterval) {
        guard let player = player,
            player.currentTime + updateDelta >= 0,
            player.currentTime + updateDelta < player.duration else { return }
        player.currentTime += updateDelta
    }
}

// MARK: - MusicInterruptionHandler

extension MusicService: MusicInterruptionDelegate {
    func interruptionHandler(_ handler: MusicInterruptionHandler, handleAction action: InterruptionAction) {
        switch action {
        case .pause: pause()
        case .play: play()
        }
    }
}

// MARK: - ClockDelegate

extension MusicService: ClockDelegate {
    func clockTicked(_ clock: Clock) {
        guard let player = player else { return }
        delegate?.musicService(self, changedPlaybackTime: player.currentTime)
    }
}

// MARK: - TrackManagerDelegate

extension MusicService: TrackManagerDelegate {
    func trackManager(_ manager: TrackManaging, updatedTrack track: Track) {
        player?.updateDuration(track.duration)
    }
}
