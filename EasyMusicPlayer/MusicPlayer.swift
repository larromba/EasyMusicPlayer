import AVFoundation
import Foundation
import Logging
import MediaPlayer

protocol MusicPlayerDelegate: AnyObject {
    func musicPlayer(_ player: MusicPlayer, threwError error: MusicError)
    func musicPlayer(_ sender: MusicPlayer, changedState state: PlayState)
    func musicPlayer(_ sender: MusicPlayer, changedPlaybackTime playbackTime: TimeInterval)
}

protocol MusicPlaying: AnyObject {
    var state: MusicPlayerState { get }

    func setDelegate(delegate: MusicPlayerDelegate)
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

// swiftlint:disable type_body_length
final class MusicPlayer: NSObject, MusicPlaying {
    private var player: AVAudioPlayer?
    private weak var delegate: MusicPlayerDelegate?
    private let trackManager: TrackManaging
    private let remote: RemoteControlling
    private let audioSession: AudioSessioning
    private let authorization: Authorizable
    private let seeker: Seekable
    private let interruptionHandler: MusicInterupptionHandling
    private let clock: Clock
    private var playState: PlayState = .stopped
    private var repeatState: RepeatState = .none

    var state: MusicPlayerState {
        return MusicPlayerState(
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
         authorization: Authorizable, seeker: Seekable, interruptionHandler: MusicInterupptionHandling,
         clock: Clock) {
        self.trackManager = trackManager
        self.remote = remote
        self.audioSession = audioSession
        self.authorization = authorization
        self.seeker = seeker
        self.interruptionHandler = interruptionHandler
        self.clock = clock

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

    func setDelegate(delegate: MusicPlayerDelegate) {
        self.delegate = delegate
    }

    func setRepeatState(_ repeatState: RepeatState) {
        self.repeatState = repeatState
    }

    func setTime(_ time: TimeInterval) {
        guard let player = player else { return }
        player.currentTime = time
        delegate?.musicPlayer(self, changedPlaybackTime: time)
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
                    let player = try AVAudioPlayer(contentsOf: assetUrl)
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

        switch repeatState {
        case .none:
            guard trackManager.cueNext() else {
                trackManager.cueStart()
                changePlayState(.finished)
                return
            }
        case .one:
            break
        case .all:
            let result = trackManager.cueNext()
            if !result {
                trackManager.cueStart()
            }
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
    private func changePlaybackPosition(_ event: MPChangePlaybackPositionCommandEvent) {
        player?.currentTime = event.positionTime
    }

    @objc
    private func seekForward(_ event: MPSeekCommandEvent) {
        guard player != nil else { return }
        switch event.type {
        case .beginSeeking:
            seeker.startSeekingWithAction(.forward)
        case .endSeeking:
            seeker.stopSeeking()
        }
    }

    @objc
    private func seekBackward(_ event: MPSeekCommandEvent) {
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
        delegate?.musicPlayer(self, threwError: error)
    }

    private func changePlayState(_ state: PlayState) {
        playState = state
        delegate?.musicPlayer(self, changedState: state)
    }

    private func authorizeThenPerform(_ block: @escaping (() -> Void)) {
        guard authorization.isAuthorized else {
            authorization.authorize({ (_ success: Bool) in
                guard success else {
                    self.throwError(.authorization)
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

extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else {
            throwError(.avError)
            return
        }
        next()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        throwError(.decode)
    }
}

// MARK: - SeekerDelegate

extension MusicPlayer: SeekerDelegate {
    func seeker(_ seeker: Seekable, updateDelta: TimeInterval) {
        player?.currentTime += updateDelta
    }
}

// MARK: - MusicInterupptionHandler

extension MusicPlayer: MusicInterupptionDelegate {
    func interupptionHandler(_ handler: MusicInterupptionHandler, updtedState state: MusicInterupptionState) {
        if state.isHeadphonesRemovedByMistake || state.isAudioSessionInterrupted {
            pause()
        } else {
            play()
        }
    }
}

// MARK: - ClockDelegate

extension MusicPlayer: ClockDelegate {
    func clockTicked(_ clock: Clock) {
        guard let player = player else { return }
        delegate?.musicPlayer(self, changedPlaybackTime: player.currentTime)
    }
}
