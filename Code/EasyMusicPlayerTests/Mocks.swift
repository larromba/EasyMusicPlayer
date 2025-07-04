///
/// @Generated by Mockolo
///



import AVFoundation
import Combine
import Foundation
import MediaPlayer
import UIKit
@testable import EasyMusicPlayer


class URLSharableMock: URLSharable {
    init() { }


    private(set) var openCallCount = 0
    var openHandler: ((URL, [UIApplication.OpenExternalURLOptionsKey : Any], (@MainActor @Sendable (Bool) -> Void)?) -> ())?
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?) {
        openCallCount += 1
        if let openHandler = openHandler {
            openHandler(url, options, completion)
        }
        
    }
}

class QueueMock: Queue {
    init() { }
    init(maxConcurrentOperationCount: Int = 0) {
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
    }


    private(set) var maxConcurrentOperationCountSetCallCount = 0
    var maxConcurrentOperationCount: Int = 0 { didSet { maxConcurrentOperationCountSetCallCount += 1 } }

    private(set) var addOperationCallCount = 0
    var addOperationHandler: ((Operation) -> ())?
    func addOperation(_ op: Operation) {
        addOperationCallCount += 1
        if let addOperationHandler = addOperationHandler {
            addOperationHandler(op)
        }
        
    }

    private(set) var addOperationBlockCallCount = 0
    var addOperationBlockHandler: ((@escaping @Sendable () -> Void) -> ())?
    func addOperation(_ block: @escaping @Sendable () -> Void) {
        addOperationBlockCallCount += 1
        if let addOperationBlockHandler = addOperationBlockHandler {
            addOperationBlockHandler(block)
        }
        
    }

    private(set) var cancelAllOperationsCallCount = 0
    var cancelAllOperationsHandler: (() -> ())?
    func cancelAllOperations() {
        cancelAllOperationsCallCount += 1
        if let cancelAllOperationsHandler = cancelAllOperationsHandler {
            cancelAllOperationsHandler()
        }
        
    }
}

class NowPlayingInfoCenterMock: NowPlayingInfoCenter {
    init() { }
    init(nowPlayingInfo: [String: Any]? = nil) {
        self.nowPlayingInfo = nowPlayingInfo
    }


    private(set) var nowPlayingInfoSetCallCount = 0
    var nowPlayingInfo: [String: Any]? = nil { didSet { nowPlayingInfoSetCallCount += 1 } }
}

class SoundEffectingMock: SoundEffecting {
    init() { }


    private(set) var playCallCount = 0
    var playHandler: ((SoundEffect) -> ())?
    func play(_ sound: SoundEffect) {
        playCallCount += 1
        if let playHandler = playHandler {
            playHandler(sound)
        }
        
    }
}

class MusicLibraryableMock: MusicLibraryable, @unchecked Sendable {
    init() { }


    private(set) var makePlaylistCallCount = 0
    var makePlaylistHandler: ((Bool) -> [MPMediaItem])?
    func makePlaylist(isShuffled: Bool) -> [MPMediaItem] {
        makePlaylistCallCount += 1
        if let makePlaylistHandler = makePlaylistHandler {
            return makePlaylistHandler(isShuffled)
        }
        return [MPMediaItem]()
    }

    private(set) var findTracksCallCount = 0
    var findTracksHandler: (([MPMediaEntityPersistentID]) -> [MPMediaItem])?
    func findTracks(with ids: [MPMediaEntityPersistentID]) -> [MPMediaItem] {
        findTracksCallCount += 1
        if let findTracksHandler = findTracksHandler {
            return findTracksHandler(ids)
        }
        return [MPMediaItem]()
    }

    private(set) var areTrackIDsValidCallCount = 0
    var areTrackIDsValidHandler: (([MPMediaEntityPersistentID]) -> Bool)?
    func areTrackIDsValid(_ ids: [MPMediaEntityPersistentID]) -> Bool {
        areTrackIDsValidCallCount += 1
        if let areTrackIDsValidHandler = areTrackIDsValidHandler {
            return areTrackIDsValidHandler(ids)
        }
        return false
    }
}

class AudioSessionRouteDescriptionMock: AudioSessionRouteDescription, @unchecked Sendable {
    init() { }
    init(inputs: [AVAudioSessionPortDescription] = [AVAudioSessionPortDescription](), outputs: [AVAudioSessionPortDescription] = [AVAudioSessionPortDescription](), outputRoutes: [AVAudioSession.Port] = [AVAudioSession.Port]()) {
        self.inputs = inputs
        self.outputs = outputs
        self.outputRoutes = outputRoutes
    }



    var inputs: [AVAudioSessionPortDescription] = [AVAudioSessionPortDescription]()


    var outputs: [AVAudioSessionPortDescription] = [AVAudioSessionPortDescription]()


    var outputRoutes: [AVAudioSession.Port] = [AVAudioSession.Port]()
}

class MusicPlayableMock: MusicPlayable, @unchecked Sendable {
    init() { }
    init(info: MusicPlayerInformation) {
        self._info = info
    }


    var state: AnyPublisher<MusicPlayerState, Never> { return self.stateSubject.eraseToAnyPublisher() }
    private(set) var stateSubject = PassthroughSubject<MusicPlayerState, Never>()


    private var _info: MusicPlayerInformation! 
    var info: MusicPlayerInformation {
        get { return _info }
        set { _info = newValue }
    }

    private(set) var authorizeCallCount = 0
    var authorizeHandler: (() -> ())?
    func authorize() {
        authorizeCallCount += 1
        if let authorizeHandler = authorizeHandler {
            authorizeHandler()
        }
        
    }

    private(set) var playCallCount = 0
    var playHandler: ((MPMediaItem) -> ())?
    func play(_ track: MPMediaItem) {
        playCallCount += 1
        if let playHandler = playHandler {
            playHandler(track)
        }
        
    }

    private(set) var playPositionCallCount = 0
    var playPositionHandler: ((MusicQueueTrackPosition) -> ())?
    func play(_ position: MusicQueueTrackPosition) {
        playPositionCallCount += 1
        if let playPositionHandler = playPositionHandler {
            playPositionHandler(position)
        }
        
    }

    private(set) var pauseCallCount = 0
    var pauseHandler: (() -> ())?
    func pause() {
        pauseCallCount += 1
        if let pauseHandler = pauseHandler {
            pauseHandler()
        }
        
    }

    private(set) var togglePlayPauseCallCount = 0
    var togglePlayPauseHandler: (() -> ())?
    func togglePlayPause() {
        togglePlayPauseCallCount += 1
        if let togglePlayPauseHandler = togglePlayPauseHandler {
            togglePlayPauseHandler()
        }
        
    }

    private(set) var stopCallCount = 0
    var stopHandler: (() -> ())?
    func stop() {
        stopCallCount += 1
        if let stopHandler = stopHandler {
            stopHandler()
        }
        
    }

    private(set) var previousCallCount = 0
    var previousHandler: (() -> ())?
    func previous() {
        previousCallCount += 1
        if let previousHandler = previousHandler {
            previousHandler()
        }
        
    }

    private(set) var nextCallCount = 0
    var nextHandler: (() -> ())?
    func next() {
        nextCallCount += 1
        if let nextHandler = nextHandler {
            nextHandler()
        }
        
    }

    private(set) var shuffleCallCount = 0
    var shuffleHandler: (() -> ())?
    func shuffle() {
        shuffleCallCount += 1
        if let shuffleHandler = shuffleHandler {
            shuffleHandler()
        }
        
    }

    private(set) var toggleRepeatModeCallCount = 0
    var toggleRepeatModeHandler: (() -> ())?
    func toggleRepeatMode() {
        toggleRepeatModeCallCount += 1
        if let toggleRepeatModeHandler = toggleRepeatModeHandler {
            toggleRepeatModeHandler()
        }
        
    }

    private(set) var toggleLofiCallCount = 0
    var toggleLofiHandler: (() -> ())?
    func toggleLofi() {
        toggleLofiCallCount += 1
        if let toggleLofiHandler = toggleLofiHandler {
            toggleLofiHandler()
        }
        
    }

    private(set) var toggleDistortionCallCount = 0
    var toggleDistortionHandler: (() -> ())?
    func toggleDistortion() {
        toggleDistortionCallCount += 1
        if let toggleDistortionHandler = toggleDistortionHandler {
            toggleDistortionHandler()
        }
        
    }

    private(set) var setRepeatModeCallCount = 0
    var setRepeatModeHandler: ((RepeatMode) -> ())?
    func setRepeatMode(_ repeatMode: RepeatMode) {
        setRepeatModeCallCount += 1
        if let setRepeatModeHandler = setRepeatModeHandler {
            setRepeatModeHandler(repeatMode)
        }
        
    }

    private(set) var setClockCallCount = 0
    var setClockHandler: ((TimeInterval, Bool) -> ())?
    func setClock(_ timeInterval: TimeInterval, isScrubbing: Bool) {
        setClockCallCount += 1
        if let setClockHandler = setClockHandler {
            setClockHandler(timeInterval, isScrubbing)
        }
        
    }

    private(set) var startSeekingCallCount = 0
    var startSeekingHandler: ((SeekDirection) -> ())?
    func startSeeking(_ direction: SeekDirection) {
        startSeekingCallCount += 1
        if let startSeekingHandler = startSeekingHandler {
            startSeekingHandler(direction)
        }
        
    }

    private(set) var stopSeekingCallCount = 0
    var stopSeekingHandler: (() -> ())?
    func stopSeeking() {
        stopSeekingCallCount += 1
        if let stopSeekingHandler = stopSeekingHandler {
            stopSeekingHandler()
        }
        
    }
}

class MusicQueuableMock: MusicQueuable, @unchecked Sendable {
    init() { }
    init(currentTrack: MPMediaItem? = nil, repeatMode: RepeatMode, currentTrackIndex: Int = 0, tracks: [MPMediaItem] = [MPMediaItem]()) {
        self.currentTrack = currentTrack
        self._repeatMode = repeatMode
        self.currentTrackIndex = currentTrackIndex
        self.tracks = tracks
    }



    var currentTrack: MPMediaItem? = nil

    private(set) var repeatModeSetCallCount = 0
    private var _repeatMode: RepeatMode!  { didSet { repeatModeSetCallCount += 1 } }
    var repeatMode: RepeatMode {
        get { return _repeatMode }
        set { _repeatMode = newValue }
    }


    var currentTrackIndex: Int = 0


    var tracks: [MPMediaItem] = [MPMediaItem]()

    private(set) var primeCallCount = 0
    var primeHandler: ((MPMediaItem) -> ())?
    func prime(_ track: MPMediaItem) {
        primeCallCount += 1
        if let primeHandler = primeHandler {
            primeHandler(track)
        }
        
    }

    private(set) var trackCallCount = 0
    var trackHandler: ((MusicQueueTrackPosition) -> MPMediaItem?)?
    func track(for position: MusicQueueTrackPosition) -> MPMediaItem? {
        trackCallCount += 1
        if let trackHandler = trackHandler {
            return trackHandler(position)
        }
        return nil
    }

    private(set) var loadCallCount = 0
    var loadHandler: (() -> ())?
    func load() {
        loadCallCount += 1
        if let loadHandler = loadHandler {
            loadHandler()
        }
        
    }

    private(set) var createCallCount = 0
    var createHandler: (() -> ())?
    func create() {
        createCallCount += 1
        if let createHandler = createHandler {
            createHandler()
        }
        
    }

    private(set) var hasUpdatesCallCount = 0
    var hasUpdatesHandler: (() -> Bool)?
    func hasUpdates() -> Bool {
        hasUpdatesCallCount += 1
        if let hasUpdatesHandler = hasUpdatesHandler {
            return hasUpdatesHandler()
        }
        return false
    }

    private(set) var toggleRepeatModeCallCount = 0
    var toggleRepeatModeHandler: (() -> ())?
    func toggleRepeatMode() {
        toggleRepeatModeCallCount += 1
        if let toggleRepeatModeHandler = toggleRepeatModeHandler {
            toggleRepeatModeHandler()
        }
        
    }
}

class AudioClockingMock: AudioClocking, @unchecked Sendable {
    init() { }


    private(set) var startCallCount = 0
    var startHandler: (() -> ())?
    func start() {
        startCallCount += 1
        if let startHandler = startHandler {
            startHandler()
        }
        
    }

    private(set) var stopCallCount = 0
    var stopHandler: (() -> ())?
    func stop() {
        stopCallCount += 1
        if let stopHandler = stopHandler {
            stopHandler()
        }
        
    }

    private(set) var setCallbackCallCount = 0
    var setCallbackHandler: ((AudioClockCallback) -> ())?
    func setCallback(_ callback: AudioClockCallback) {
        setCallbackCallCount += 1
        if let setCallbackHandler = setCallbackHandler {
            setCallbackHandler(callback)
        }
        
    }
}

class SeekableMock: Seekable, @unchecked Sendable {
    init() { }


    private(set) var setSeekCallbackCallCount = 0
    var setSeekCallbackHandler: ((SeekCallback) -> ())?
    func setSeekCallback(_ seekCallback: SeekCallback) {
        setSeekCallbackCallCount += 1
        if let setSeekCallbackHandler = setSeekCallbackHandler {
            setSeekCallbackHandler(seekCallback)
        }
        
    }

    private(set) var seekCallCount = 0
    var seekHandler: ((SeekDirection) -> ())?
    func seek(_ action: SeekDirection) {
        seekCallCount += 1
        if let seekHandler = seekHandler {
            seekHandler(action)
        }
        
    }

    private(set) var stopCallCount = 0
    var stopHandler: (() -> ())?
    func stop() {
        stopCallCount += 1
        if let stopHandler = stopHandler {
            stopHandler()
        }
        
    }
}

class MusicAuthorizableMock: MusicAuthorizable, @unchecked Sendable {
    init() { }
    init(isAuthorized: Bool = false) {
        self.isAuthorized = isAuthorized
    }



    var isAuthorized: Bool = false

    private(set) var authorizeCallCount = 0
    var authorizeHandler: ((@escaping MusicAuthorizationCompletion) -> ())?
    func authorize(_ completion: @escaping MusicAuthorizationCompletion) {
        authorizeCallCount += 1
        if let authorizeHandler = authorizeHandler {
            authorizeHandler(completion)
        }
        
    }
}

class MusicInterruptionHandlingMock: MusicInterruptionHandling, @unchecked Sendable {
    init() { }
    init(isPlaying: Bool = false) {
        self.isPlaying = isPlaying
    }


    private(set) var isPlayingSetCallCount = 0
    var isPlaying: Bool = false { didSet { isPlayingSetCallCount += 1 } }

    private(set) var setCallbackCallCount = 0
    var setCallbackHandler: ((MusicInterruptionHandlerCallback) -> ())?
    func setCallback(_ callback: MusicInterruptionHandlerCallback) {
        setCallbackCallCount += 1
        if let setCallbackHandler = setCallbackHandler {
            setCallbackHandler(callback)
        }
        
    }
}

class AudioSessionMock: AudioSession, @unchecked Sendable {
    init() { }
    init(currentRoute: AVAudioSessionRouteDescription, outputRoutes: [AVAudioSession.Port] = [AVAudioSession.Port]()) {
        self._currentRoute = currentRoute
        self.outputRoutes = outputRoutes
    }



    private var _currentRoute: AVAudioSessionRouteDescription! 
    var currentRoute: AVAudioSessionRouteDescription {
        get { return _currentRoute }
        set { _currentRoute = newValue }
    }


    var outputRoutes: [AVAudioSession.Port] = [AVAudioSession.Port]()
}

