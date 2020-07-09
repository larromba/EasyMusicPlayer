import AVFoundation
import Foundation
import Logging
import MediaPlayer

protocol MusicServiceDelegate: AnyObject {
    func musicService(_ service: MusicService, threwError error: MusicError)
    func musicService(_ service: MusicService, changedState state: PlayState)
    func musicService(_ service: MusicService, changedPlaybackTime playbackTime: TimeInterval)
}

// sourcery: name = MusicService
protocol MusicServicing: AnyObject, Mockable {
    var state: MusicServiceState { get }

    func setDelegate(delegate: MusicServiceDelegate)
    func setRepeatState(_ repeatState: RepeatState)
    func setTime(_ time: TimeInterval)
    func play()
    func stop()
    func pause()
    func previous()
    func next()
    func shuffle()
    func skip()
}

final class MusicService: NSObject, MusicServicing {
    private var player: AudioPlayer?
    private weak var delegate: MusicServiceDelegate?
    private let trackManager: TrackManaging
    private let remote: RemoteControlling
    private let audioSession: AudioSessioning
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
            currentTrack: trackManager.currentTrack,
            time: player?.currentTime ?? 0.0,
            playState: playState,
            repeatState: repeatState
        )
    }

    init(trackManager: TrackManaging, remote: RemoteControlling, audioSession: AudioSessioning,
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillTerminate(_:)),
            name: NSNotification.Name.UIApplicationWillTerminate,
            object: nil
        )

        seeker.setDelegate(self)
        interruptionHandler.setDelegate(self)
        clock.setDelegate(self)

        remote.togglePlayPauseCommand.addTarget(self, action: #selector(togglePlayPause))
        remote.pauseCommand.addTarget(self, action: #selector(pause))
        remote.playCommand.addTarget(self, action: #selector(play))
        remote.stopCommand.addTarget(self, action: #selector(stop))
        remote.previousTrackCommand.addTarget(self, action: #selector(previous))
        remote.nextTrackCommand.addTarget(self, action: #selector(next))
        remote.seekForwardCommand.addTarget(self, action: #selector(seekForward(_:)))
        remote.seekBackwardCommand.addTarget(self, action: #selector(seekBackward(_:)))
        remote.changePlaybackPositionCommand.addTarget(self, action: #selector(changePlaybackPosition(_:)))

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

    func setDelegate(delegate: MusicServiceDelegate) {
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

    @objc
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
            guard let assetUrl = self.trackManager.currentTrack.assetURL else {
                self.throwError(.playerInit)
                return
            }

            if self.player?.url?.absoluteString != assetUrl.absoluteString {
                do {
                    let player = try self.playerFactory.makeAudioPlayer(withContentsOf: assetUrl)
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

            self.clock.start()
            self.interruptionHandler.setIsPlaying(true)
            self.changePlayState(.playing)
        })
    }

    @objc
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

    @objc
    func pause() {
        guard let player = player else { return }
        player.pause()

        clock.stop()
        seeker.stopSeeking()

        interruptionHandler.setIsPlaying(false)
        changePlayState(.paused)
    }

    @objc
    func previous() {
        stop()

        let result = trackManager.cuePrevious()
        if repeatState == .all && !result {
            trackManager.cueEnd()
        }

        play()
    }

    @objc
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

    private func setAudioSessionIsEnabled(_ isEnabled: Bool) -> Bool {
        do {
            if isEnabled {
                try audioSession.setCategory_objc(AVAudioSessionCategoryPlayback, with: [])
            }
            try audioSession.setActive_objc(isEnabled)
        } catch {
            logError(error.localizedDescription)
            return false
        }
        return true
    }

    @objc
    private func togglePlayPause() {
        if state.isPlaying {
            pause()
        } else {
            play()
        }
    }

    @objc
    private func changePlaybackPosition(_ event: ChangePlaybackPositionCommandEvent) {
        player?.currentTime = event.positionTime
    }

    @objc
    private func seekForward(_ event: SeekCommandEvent) {
        guard player != nil else { return }
        switch event.type {
        case .beginSeeking:
            seeker.startSeekingWithAction(.forward)
        case .endSeeking:
            seeker.stopSeeking()
        }
    }

    @objc
    private func seekBackward(_ event: SeekCommandEvent) {
        guard player != nil else { return }
        switch event.type {
        case .beginSeeking:
            seeker.startSeekingWithAction(.backward)
        case .endSeeking:
            seeker.stopSeeking()
        }
    }

    @objc
    private func applicationWillTerminate(_ notifcation: Notification) {
        cleanUp()
    }

    private func throwError(_ error: MusicError) {
        stop()
        delegate?.musicService(self, threwError: error)
    }

    private func changePlayState(_ state: PlayState) {
        playState = state
        delegate?.musicService(self, changedState: state)
    }

    private func authorizeThenPerform(_ block: @escaping (() -> Void)) {
        guard authorization.isAuthorized else {
            authorization.authorize({ [weak self] (_ success: Bool) in
                guard success else {
                    self?.throwError(.authorization)
                    return
                }
                block()
            })
            return
        }
        block()
    }

    private func cleanUp() {
        _ = setAudioSessionIsEnabled(false)

        remote.togglePlayPauseCommand.removeTarget(self)
        remote.pauseCommand.removeTarget(self)
        remote.playCommand.removeTarget(self)
        remote.previousTrackCommand.removeTarget(self)
        remote.nextTrackCommand.removeTarget(self)
        remote.seekForwardCommand.removeTarget(self)
        remote.seekBackwardCommand.removeTarget(self)
        remote.changePlaybackPositionCommand.removeTarget(self)
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
            guard trackManager.currentTrack != trackManager.tracks.last else {
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
        guard
            let player = player,
            player.currentTime + updateDelta >= 0,
            player.currentTime + updateDelta < player.duration else {
                return
        }
        player.currentTime += updateDelta
    }
}

// MARK: - MusicInterupptionHandler

extension MusicService: MusicInterruptionDelegate {
    func interruptionHandler(_ handler: MusicInterruptionHandler, updtedState state: MusicInterruptionState) {
        if state.isHeadphonesRemovedByMistake || state.isAudioSessionInterrupted {
            pause()
        } else {
            play()
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
