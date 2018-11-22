import AVFoundation
import Foundation
import MediaPlayer

protocol MusicPlayerDelegate: AnyObject {
    func musicPlayer(_ player: MusicPlayer, threwError error: MusicError)
    func musicPlayer(_ sender: MusicPlayer, changedState state: MusicPlayerState)
    func musicPlayer(_ sender: MusicPlayer, changedPlaybackTime playbackTime: TimeInterval)
}

protocol MusicPlaying: AnyObject {
    var isPlaying: Bool { get }
    var time: TimeInterval { get set }
    var volume: Float { get }
    var repeatState: RepeatState { get set }
    var currentTrackNumber: Int { get }
    var numOfTracks: Int { get }
    var currentTrack: MPMediaItem { get }

    func setDelegate(delegate: MusicPlayerDelegate)
    func play()
    func stop()
    func pause()
    func previous()
    func next()
    func shuffle()
    func skip()
}

// TODO: remove NSObject?
final class MusicPlayer: NSObject, MusicPlaying {
    private var player: AVAudioPlayer?
    private var playbackCheckTimer: Timer?
    private var seekTimer: Timer?
    private var isHeadphonesRemovedByMistake: Bool = false
    private var isPlayingInBackground: Bool = false
    private var isAudioSessionInterrupted: Bool = false
    private var seekStartDate: Date?
    private weak var delegate: MusicPlayerDelegate?
    private let trackManager: TrackManaging
    private let remote: RemoteControlling
    private let audioSession: AudioSessioning
    private let authoriztion: Authorizable

    var repeatState: RepeatState = .none
    var isPlaying: Bool {
        guard let player = player else { return false }
        return player.isPlaying
    }
    var time: TimeInterval {
        set {
            guard let player = player else { return }
            player.currentTime = newValue
            delegate?.musicPlayer(self, changedPlaybackTime: time)
        }
        get {
            guard let player = player else { return 0.0 }
            return player.currentTime
        }
    }
    var volume: Float {
        return audioSession.outputVolume
    }
    var currentTrackNumber: Int {
        return trackManager.currentTrackNumber
    }
    var numOfTracks: Int {
        return trackManager.numOfTracks
    }
    var currentTrack: MPMediaItem {
        return trackManager.currentTrack
    }

    init(trackManager: TrackManaging, remote: RemoteControlling, audioSession: AudioSessioning, authoriztion: Authorizable) {
        self.trackManager = trackManager
        self.remote = remote
        self.audioSession = audioSession
        self.authoriztion = authoriztion

        super.init()

        // TODO: put remote in another class
        remote.togglePlayPauseCommand.addTarget(self, action: #selector(togglePlayPause))
        remote.pauseCommand.addTarget(self, action: #selector(pause))
        remote.playCommand.addTarget(self, action: #selector(play))
        remote.previousTrackCommand.addTarget(self, action: #selector(previous))
        remote.nextTrackCommand.addTarget(self, action: #selector(next))
        remote.seekForwardCommand.addTarget(self, action: #selector(seekForward(_:)))
        remote.seekBackwardCommand.addTarget(self, action: #selector(seekBackward(_:)))
        remote.changePlaybackPositionCommand.addTarget(self, action: #selector(changePlaybackPosition(_:)))

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillTerminate(_:)),
            name: NSNotification.Name.UIApplicationWillTerminate,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive(_:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionRouteChange(_:)),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionInterruption(_:)),
            name: NSNotification.Name.AVAudioSessionInterruption,
            object: nil
        )

        authorizeThenPerform({
            self.trackManager.loadTracks()
            if self.trackManager.numOfTracks == 0 {
                self.trackManager.shuffleTracks()
            }
        })
    }

    deinit {
        cleanUp()
    }

    func setDelegate(delegate: MusicPlayerDelegate) {
        self.delegate = delegate
    }

    @objc
    func play() {
        authorizeThenPerform({
            guard self.trackManager.numOfTracks > 0 else {
                self.throwError(.noMusic)
                return
            }
            guard self.volume > 0.0 else {
                self.throwError(.noVolume)
                return
            }
            guard let assetUrl = self.trackManager.currentTrack.assetURL else {
                self.throwError(.playerInit)
                return
            }

            if self.player == nil || self.player?.url?.absoluteString != assetUrl.absoluteString {
                do {
                    let player = try AVAudioPlayer(contentsOf: assetUrl)
                    player.delegate = self
                    self.player = player
                } catch _ {
                    self.throwError(.playerInit)
                    return
                }
            }

            let enable = self.enableAudioSession(true)
            let prepare = self.player?.prepareToPlay() ?? false
            let play = self.player?.play() ?? false

            guard enable, prepare, play else {
                log_error("enable: \(enable), prepare: \(prepare), play: \(play)")
                self.throwError(.avError)
                return
            }

            self.startPlaybackCheckTimer()
            self.isHeadphonesRemovedByMistake = false
            self.isAudioSessionInterrupted = false
            self.delegate?.musicPlayer(self, changedState: .playing)
        })
    }

    func stop() {
        guard let player = player else {
            return
        }

        player.stop()
        self.player = nil

        stopPlaybackCheckTimer()
        stopSeekTimer()
        time = 0.0

        delegate?.musicPlayer(self, changedState: .stopped)
    }

    @objc
    func pause() {
        guard let player = player else {
            return
        }

        player.pause()

        stopPlaybackCheckTimer()
        stopSeekTimer()

        delegate?.musicPlayer(self, changedState: .paused)
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
                delegate?.musicPlayer(self, changedState: .finished)
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
            self.trackManager.shuffleTracks()
        })
    }

    func skip() {
        trackManager.removeTrack(atIndex: trackManager.currentTrackNumber)
        next()
    }

    // MARK: - private

    private func enableAudioSession(_ enable: Bool) -> Bool {
        if enable {
            do {
                try audioSession.setCategory_objc(AVAudioSessionCategoryPlayback, with: [])
            } catch {
                log_error(error.localizedDescription)
                return false
            }
        }
        do {
            try audioSession.setActive_objc(enable)
        } catch {
            log_error(error.localizedDescription)
            return false
        }
        return true
    }

    @objc
    private func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    @objc
    private func changePlaybackPosition(_ event: MPChangePlaybackPositionCommandEvent) {
        time = event.positionTime
    }

    private func seekForwardStart() {
        seekStartDate = Date()
        startSeekTimerWithAction(#selector(seekForwardTimerCallback))
    }

    private func seekForwardEnd() {
        stopSeekTimer()
    }

    // TODO: move these out - seek class?
    @objc
    private func seekForward(_ event: MPSeekCommandEvent) {
        guard player != nil else { return }
        switch event.type {
        case .beginSeeking:
            seekForwardStart()
        case .endSeeking:
            seekForwardEnd()
        }
    }

    @objc
    private func seekBackward(_ event: MPSeekCommandEvent) {
        guard player != nil else { return }
        switch event.type {
        case .beginSeeking:
            seekBackwardStart()
        case .endSeeking:
            seekBackwardEnd()
        }
    }

    private func seekBackwardStart() {
        seekStartDate = Date()
        startSeekTimerWithAction(#selector(seekBackwardTimerCallback))
    }

    private func seekBackwardEnd() {
        stopSeekTimer()
    }

    private func startPlaybackCheckTimer() {
        if playbackCheckTimer != nil {
            stopPlaybackCheckTimer()
        }
        playbackCheckTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(playbackCheckTimerCallback),
            userInfo: nil,
            repeats: true
        )
    }

    private func stopPlaybackCheckTimer() {
        playbackCheckTimer?.invalidate()
        playbackCheckTimer = nil
    }

    private func startSeekTimerWithAction(_ action: Selector) {
        if seekTimer != nil {
            stopSeekTimer()
        }
        seekTimer = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: action,
            userInfo: nil,
            repeats: true
        )
    }

    private func stopSeekTimer() {
        seekTimer?.invalidate()
        seekTimer = nil
    }

    private func throwError(_ error: MusicError) {
        stop()
        delegate?.musicPlayer(self, threwError: error)
    }

    private func authorizeThenPerform(_ block: @escaping (() -> Void)) {
        guard authoriztion.isAuthorized else {
            authoriztion.authorize({ (_ success: Bool) in
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
        _ = enableAudioSession(false)

        remote.togglePlayPauseCommand.removeTarget(self)
        remote.pauseCommand.removeTarget(self)
        remote.playCommand.removeTarget(self)
        remote.previousTrackCommand.removeTarget(self)
        remote.nextTrackCommand.removeTarget(self)
        remote.seekForwardCommand.removeTarget(self)
        remote.seekBackwardCommand.removeTarget(self)
        remote.changePlaybackPositionCommand.removeTarget(self)
    }

    // MARK: - Notifications

    // TODO: audio interupption class?
    @objc
    private func applicationWillTerminate(_ notifcation: Notification) {
        cleanUp()
    }

    @objc
    private func applicationWillResignActive(_ notifcation: Notification) {
        if isPlaying {
            isPlayingInBackground = true
        }
    }

    @objc
    private func applicationDidBecomeActive(_ notifcation: Notification) {
        isPlayingInBackground = false
    }

    @objc
    private func audioSessionRouteChange(_ notifcation: Notification) {
        guard
            let rawValue = (notifcation.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.uintValue,
            let reason = AVAudioSessionRouteChangeReason(rawValue: rawValue) else {
            return
        }
        switch reason {
        case .oldDeviceUnavailable:
            if isPlaying {
                isHeadphonesRemovedByMistake = true
                pause()
            }
        case .newDeviceAvailable:
            if !isPlaying && isHeadphonesRemovedByMistake {
                isHeadphonesRemovedByMistake = false
                play()
            }
        default:
            break
        }
    }

    @objc
    private func audioSessionInterruption(_ notification: Notification) {
        guard
            let rawValue = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let reason = AVAudioSessionInterruptionType(rawValue: rawValue) else {
                return
        }
        switch reason {
        case .began:
            if isPlayingInBackground || isPlaying {
                isAudioSessionInterrupted = true
                pause()
            }
        case .ended:
            if !isPlaying && isAudioSessionInterrupted {
                isAudioSessionInterrupted = false
                play()
            }
        }
    }

    // MARK: - Timer

    @objc
    private func playbackCheckTimerCallback() {
        guard let player = player else {
            return
        }
        delegate?.musicPlayer(self, changedPlaybackTime: player.currentTime)
    }

    @objc
    private func seekForwardTimerCallback() {
        guard let player = player, seekTimer != nil else {
            return
        }
        player.currentTime += 1.0
    }

    @objc
    private func seekBackwardTimerCallback() {
        guard let player = player, seekTimer != nil else {
            return
        }
        player.currentTime -= 1.0
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
