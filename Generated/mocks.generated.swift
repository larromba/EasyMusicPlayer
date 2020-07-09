// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

@testable import EasyMusic
import MediaPlayer

// MARK: - Sourcery Helper

protocol _StringRawRepresentable: RawRepresentable {
    var rawValue: String { get }
}

struct _Variable<T> {
    let date = Date()
    var variable: T?

    init(_ variable: T?) {
        self.variable = variable
    }
}

final class _Invocation {
    let name: String
    let date = Date()
    private var parameters: [String: Any] = [:]

    init(name: String) {
        self.name = name
    }

    fileprivate func set<T: _StringRawRepresentable>(parameter: Any, forKey key: T) {
        parameters[key.rawValue] = parameter
    }
    func parameter<T: _StringRawRepresentable>(for key: T) -> Any? {
        return parameters[key.rawValue]
    }
}

final class _Actions {
  enum Keys: String, _StringRawRepresentable {
      case returnValue
      case defaultReturnValue
      case error
  }
  private var invocations: [_Invocation] = []

  // MARK: - returnValue

  func set<T: _StringRawRepresentable>(returnValue value: Any, for functionName: T) {
      let invocation = self.invocation(for: functionName)
      invocation.set(parameter: value, forKey: Keys.returnValue)
  }
  func returnValue<T: _StringRawRepresentable>(for functionName: T) -> Any? {
      let invocation = self.invocation(for: functionName)
      return invocation.parameter(for: Keys.returnValue) ?? invocation.parameter(for: Keys.defaultReturnValue)
  }

  // MARK: - defaultReturnValue

  fileprivate func set<T: _StringRawRepresentable>(defaultReturnValue value: Any, for functionName: T) {
      let invocation = self.invocation(for: functionName)
      invocation.set(parameter: value, forKey: Keys.defaultReturnValue)
  }
  fileprivate func defaultReturnValue<T: _StringRawRepresentable>(for functionName: T) -> Any? {
      let invocation = self.invocation(for: functionName)
      return invocation.parameter(for: Keys.defaultReturnValue) as? (() -> Void)
  }

  // MARK: - error

  func set<T: _StringRawRepresentable>(error: Error, for functionName: T) {
      let invocation = self.invocation(for: functionName)
      invocation.set(parameter: error, forKey: Keys.error)
  }
  func error<T: _StringRawRepresentable>(for functionName: T) -> Error? {
      let invocation = self.invocation(for: functionName)
      return invocation.parameter(for: Keys.error) as? Error
  }

  // MARK: - private

  private func invocation<T: _StringRawRepresentable>(for name: T) -> _Invocation {
      if let invocation = invocations.filter({ $0.name == name.rawValue }).first {
          return invocation
      }
      let invocation = _Invocation(name: name.rawValue)
      invocations += [invocation]
      return invocation
  }
}

final class _Invocations {
    private var history = [_Invocation]()

    fileprivate func record(_ invocation: _Invocation) {
        history += [invocation]
    }

    func isInvoked<T: _StringRawRepresentable>(_ name: T) -> Bool {
        return history.contains(where: { $0.name == name.rawValue })
    }

    func count<T: _StringRawRepresentable>(_ name: T) -> Int {
        return history.filter {  $0.name == name.rawValue }.count
    }

    func all() -> [_Invocation] {
        return history.sorted { $0.date < $1.date }
    }

    func find<T: _StringRawRepresentable>(_ name: T) -> [_Invocation] {
        return history.filter {  $0.name == name.rawValue }.sorted { $0.date < $1.date }
    }

    func reset() {
        history.removeAll()
    }
}

// MARK: - Sourcery Mocks

class MockAlertController: NSObject, AlertControlling {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - showAlert

    func showAlert(_ alert: Alert) {
        let functionName = showAlert1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: alert, forKey: showAlert1.params.alert)
        invocations.record(invocation)
    }

    enum showAlert1: String, _StringRawRepresentable {
        case name = "showAlert1"
        enum params: String, _StringRawRepresentable {
            case alert = "showAlert(_alert:Alert).alert"
        }
    }
}

class MockAppController: NSObject, AppControlling {
}

class MockAudioPlayer: NSObject, AudioPlayer {
    var isPlaying: Bool {
        get { return _isPlaying }
        set(value) { _isPlaying = value; _isPlayingHistory.append(_Variable(value)) }
    }
    var _isPlaying: Bool!
    var _isPlayingHistory: [_Variable<Bool?>] = []
    var duration: TimeInterval {
        get { return _duration }
        set(value) { _duration = value; _durationHistory.append(_Variable(value)) }
    }
    var _duration: TimeInterval!
    var _durationHistory: [_Variable<TimeInterval?>] = []
    var delegate: AVAudioPlayerDelegate? {
        get { return _delegate }
        set(value) { _delegate = value; _delegateHistory.append(_Variable(value)) }
    }
    var _delegate: AVAudioPlayerDelegate?
    var _delegateHistory: [_Variable<AVAudioPlayerDelegate?>] = []
    var currentTime: TimeInterval {
        get { return _currentTime }
        set(value) { _currentTime = value; _currentTimeHistory.append(_Variable(value)) }
    }
    var _currentTime: TimeInterval!
    var _currentTimeHistory: [_Variable<TimeInterval?>] = []
    var url: URL? {
        get { return _url }
        set(value) { _url = value; _urlHistory.append(_Variable(value)) }
    }
    var _url: URL?
    var _urlHistory: [_Variable<URL?>] = []
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - prepareToPlay

    func prepareToPlay() -> Bool {
        let functionName = prepareToPlay1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as! Bool
    }

    enum prepareToPlay1: String, _StringRawRepresentable {
        case name = "prepareToPlay1"
    }

    // MARK: - play

    func play() -> Bool {
        let functionName = play2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as! Bool
    }

    enum play2: String, _StringRawRepresentable {
        case name = "play2"
    }

    // MARK: - pause

    func pause() {
        let functionName = pause3.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum pause3: String, _StringRawRepresentable {
        case name = "pause3"
    }

    // MARK: - stop

    func stop() {
        let functionName = stop4.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum stop4: String, _StringRawRepresentable {
        case name = "stop4"
    }

    // MARK: - init

    required init(contentsOf url: URL) {
        let functionName = init5.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: url, forKey: init5.params.url)
        invocations.record(invocation)
    }

    enum init5: String, _StringRawRepresentable {
        case name = "init5"
        enum params: String, _StringRawRepresentable {
            case url = "init(contentsOfurl:URL).url"
        }
    }
}

class MockAudioPlayerFactory: NSObject, AudioPlayerFactoring {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - makeAudioPlayer

    func makeAudioPlayer(withContentsOf url: URL) throws -> AudioPlayer {
        let functionName = makeAudioPlayer1.name
        if let error = actions.error(for: functionName) {
            throw error
        }
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: url, forKey: makeAudioPlayer1.params.url)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as! AudioPlayer
    }

    enum makeAudioPlayer1: String, _StringRawRepresentable {
        case name = "makeAudioPlayer1"
        enum params: String, _StringRawRepresentable {
            case url = "makeAudioPlayer(withContentsOfurl:URL).url"
        }
    }
}

class MockAudioSession: NSObject, AudioSessioning {
    var outputVolume: Float {
        get { return _outputVolume }
        set(value) { _outputVolume = value; _outputVolumeHistory.append(_Variable(value)) }
    }
    var _outputVolume: Float! = 1
    var _outputVolumeHistory: [_Variable<Float?>] = []
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - setCategory_objc

    func setCategory_objc(_ category: AVAudioSession.Category, with options: AVAudioSession.CategoryOptions) throws {
        let functionName = setCategory_objc1.name
        if let error = actions.error(for: functionName) {
            throw error
        }
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: category, forKey: setCategory_objc1.params.category)
        invocation.set(parameter: options, forKey: setCategory_objc1.params.options)
        invocations.record(invocation)
    }

    enum setCategory_objc1: String, _StringRawRepresentable {
        case name = "setCategory_objc1"
        enum params: String, _StringRawRepresentable {
            case category = "setCategory_objc(_category:AVAudioSession.Category,withoptions:AVAudioSession.CategoryOptions).category"
            case options = "setCategory_objc(_category:AVAudioSession.Category,withoptions:AVAudioSession.CategoryOptions).options"
        }
    }

    // MARK: - setActive_objc

    func setActive_objc(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
        let functionName = setActive_objc2.name
        if let error = actions.error(for: functionName) {
            throw error
        }
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: active, forKey: setActive_objc2.params.active)
        invocation.set(parameter: options, forKey: setActive_objc2.params.options)
        invocations.record(invocation)
    }

    enum setActive_objc2: String, _StringRawRepresentable {
        case name = "setActive_objc2"
        enum params: String, _StringRawRepresentable {
            case active = "setActive_objc(_active:Bool,options:AVAudioSession.SetActiveOptions).active"
            case options = "setActive_objc(_active:Bool,options:AVAudioSession.SetActiveOptions).options"
        }
    }
}

class MockAuthorization: NSObject, Authorization {
    var isAuthorized: Bool {
        get { return _isAuthorized }
        set(value) { _isAuthorized = value; _isAuthorizedHistory.append(_Variable(value)) }
    }
    var _isAuthorized: Bool! = true
    var _isAuthorizedHistory: [_Variable<Bool?>] = []
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - authorize

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void)) {
        let functionName = authorize1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: completion, forKey: authorize1.params.completion)
        invocations.record(invocation)
    }

    enum authorize1: String, _StringRawRepresentable {
        case name = "authorize1"
        enum params: String, _StringRawRepresentable {
            case completion = "authorize(_completion:@escaping((_success:Bool)->Void)).completion"
        }
    }
}

class MockChangePlaybackPositionCommandEvent: NSObject, ChangePlaybackPositionCommandEvent {
    var positionTime: TimeInterval {
        get { return _positionTime }
        set(value) { _positionTime = value; _positionTimeHistory.append(_Variable(value)) }
    }
    var _positionTime: TimeInterval!
    var _positionTimeHistory: [_Variable<TimeInterval?>] = []
}

class MockChangeRepeatModeCommandEvent: NSObject, ChangeRepeatModeCommandEvent {
    var repeatType: MPRepeatType {
        get { return _repeatType }
        set(value) { _repeatType = value; _repeatTypeHistory.append(_Variable(value)) }
    }
    var _repeatType: MPRepeatType!
    var _repeatTypeHistory: [_Variable<MPRepeatType?>] = []
}

class MockClock: NSObject, Clocking {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - start

    func start() {
        let functionName = start1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum start1: String, _StringRawRepresentable {
        case name = "start1"
    }

    // MARK: - stop

    func stop() {
        let functionName = stop2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum stop2: String, _StringRawRepresentable {
        case name = "stop2"
    }

    // MARK: - setDelegate

    func setDelegate(_ delegate: ClockDelegate) {
        let functionName = setDelegate3.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: delegate, forKey: setDelegate3.params.delegate)
        invocations.record(invocation)
    }

    enum setDelegate3: String, _StringRawRepresentable {
        case name = "setDelegate3"
        enum params: String, _StringRawRepresentable {
            case delegate = "setDelegate(_delegate:ClockDelegate).delegate"
        }
    }
}

class MockControlsController: NSObject, ControlsControlling {
    var repeatButtonState: RepeatState? {
        get { return _repeatButtonState }
        set(value) { _repeatButtonState = value; _repeatButtonStateHistory.append(_Variable(value)) }
    }
    var _repeatButtonState: RepeatState?
    var _repeatButtonStateHistory: [_Variable<RepeatState?>] = []
    var playButtonState: PlayState? {
        get { return _playButtonState }
        set(value) { _playButtonState = value; _playButtonStateHistory.append(_Variable(value)) }
    }
    var _playButtonState: PlayState?
    var _playButtonStateHistory: [_Variable<PlayState?>] = []
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - setDelegate

    func setDelegate(_ delegate: ControlsDelegate) {
        let functionName = setDelegate1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: delegate, forKey: setDelegate1.params.delegate)
        invocations.record(invocation)
    }

    enum setDelegate1: String, _StringRawRepresentable {
        case name = "setDelegate1"
        enum params: String, _StringRawRepresentable {
            case delegate = "setDelegate(_delegate:ControlsDelegate).delegate"
        }
    }

    // MARK: - setMusicServiceState

    func setMusicServiceState(_ musicServiceState: MusicServiceState) {
        let functionName = setMusicServiceState2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: musicServiceState, forKey: setMusicServiceState2.params.musicServiceState)
        invocations.record(invocation)
    }

    enum setMusicServiceState2: String, _StringRawRepresentable {
        case name = "setMusicServiceState2"
        enum params: String, _StringRawRepresentable {
            case musicServiceState = "setMusicServiceState(_musicServiceState:MusicServiceState).musicServiceState"
        }
    }

    // MARK: - setRepeatState

    func setRepeatState(_ repeatState: RepeatState) {
        let functionName = setRepeatState3.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: repeatState, forKey: setRepeatState3.params.repeatState)
        invocations.record(invocation)
    }

    enum setRepeatState3: String, _StringRawRepresentable {
        case name = "setRepeatState3"
        enum params: String, _StringRawRepresentable {
            case repeatState = "setRepeatState(_repeatState:RepeatState).repeatState"
        }
    }

    // MARK: - setControlsPlaying

    func setControlsPlaying() {
        let functionName = setControlsPlaying4.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum setControlsPlaying4: String, _StringRawRepresentable {
        case name = "setControlsPlaying4"
    }

    // MARK: - setControlsPaused

    func setControlsPaused() {
        let functionName = setControlsPaused5.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum setControlsPaused5: String, _StringRawRepresentable {
        case name = "setControlsPaused5"
    }

    // MARK: - setControlsStopped

    func setControlsStopped() {
        let functionName = setControlsStopped6.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum setControlsStopped6: String, _StringRawRepresentable {
        case name = "setControlsStopped6"
    }
}

class MockControlsViewController: NSObject, ControlsViewControlling {
    var viewState: ControlsViewStating? {
        get { return _viewState }
        set(value) { _viewState = value; _viewStateHistory.append(_Variable(value)) }
    }
    var _viewState: ControlsViewStating?
    var _viewStateHistory: [_Variable<ControlsViewStating?>] = []
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - setDelegate

    func setDelegate(_ delegate: ControlsViewDelegate) {
        let functionName = setDelegate1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: delegate, forKey: setDelegate1.params.delegate)
        invocations.record(invocation)
    }

    enum setDelegate1: String, _StringRawRepresentable {
        case name = "setDelegate1"
        enum params: String, _StringRawRepresentable {
            case delegate = "setDelegate(_delegate:ControlsViewDelegate).delegate"
        }
    }
}

class MockDataManger: NSObject, DataManaging {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - save<T: Keyable, U>

    func save<T: Keyable, U>(_ data: U?, key: T) {
        let functionName = save1.name
        let invocation = _Invocation(name: functionName.rawValue)
        if let data = data {
            invocation.set(parameter: data, forKey: save1.params.data)
        }
        invocation.set(parameter: key, forKey: save1.params.key)
        invocations.record(invocation)
    }

    enum save1: String, _StringRawRepresentable {
        case name = "save1"
        enum params: String, _StringRawRepresentable {
            case data = "save<T:Keyable,U>(_data:U?,key:T).data"
            case key = "save<T:Keyable,U>(_data:U?,key:T).key"
        }
    }

    // MARK: - load<T: Keyable, U>

    func load<T: Keyable, U>(key: T) -> U? {
        let functionName = load2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: key, forKey: load2.params.key)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as? U
    }

    enum load2: String, _StringRawRepresentable {
        case name = "load2"
        enum params: String, _StringRawRepresentable {
            case key = "load<T:Keyable,U>(key:T).key"
        }
    }
}

class MockInfoController: NSObject, InfoControlling {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - setInfoFromTrack

    func setInfoFromTrack(_ track: Track) {
        let functionName = setInfoFromTrack1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: track, forKey: setInfoFromTrack1.params.track)
        invocations.record(invocation)
    }

    enum setInfoFromTrack1: String, _StringRawRepresentable {
        case name = "setInfoFromTrack1"
        enum params: String, _StringRawRepresentable {
            case track = "setInfoFromTrack(_track:Track).track"
        }
    }

    // MARK: - clearInfo

    func clearInfo() {
        let functionName = clearInfo2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum clearInfo2: String, _StringRawRepresentable {
        case name = "clearInfo2"
    }

    // MARK: - setTime

    func setTime(_ time: TimeInterval, duration: TimeInterval) {
        let functionName = setTime3.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: time, forKey: setTime3.params.time)
        invocation.set(parameter: duration, forKey: setTime3.params.duration)
        invocations.record(invocation)
    }

    enum setTime3: String, _StringRawRepresentable {
        case name = "setTime3"
        enum params: String, _StringRawRepresentable {
            case time = "setTime(_time:TimeInterval,duration:TimeInterval).time"
            case duration = "setTime(_time:TimeInterval,duration:TimeInterval).duration"
        }
    }

    // MARK: - setTrackPosition

    func setTrackPosition(_ trackPosition: Int, totalTracks: Int) {
        let functionName = setTrackPosition4.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: trackPosition, forKey: setTrackPosition4.params.trackPosition)
        invocation.set(parameter: totalTracks, forKey: setTrackPosition4.params.totalTracks)
        invocations.record(invocation)
    }

    enum setTrackPosition4: String, _StringRawRepresentable {
        case name = "setTrackPosition4"
        enum params: String, _StringRawRepresentable {
            case trackPosition = "setTrackPosition(_trackPosition:Int,totalTracks:Int).trackPosition"
            case totalTracks = "setTrackPosition(_trackPosition:Int,totalTracks:Int).totalTracks"
        }
    }
}

class MockInfoViewController: NSObject, InfoViewControlling {
    var viewState: InfoViewStating? {
        get { return _viewState }
        set(value) { _viewState = value; _viewStateHistory.append(_Variable(value)) }
    }
    var _viewState: InfoViewStating?
    var _viewStateHistory: [_Variable<InfoViewStating?>] = []
}

class MockMediaLibrary: NSObject, MediaLibraryAuthorizable {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - authorizationStatus

    static func authorizationStatus() -> MPMediaLibraryAuthorizationStatus {
        let functionName = authorizationStatus1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
        actions.set(defaultReturnValue: MPMediaLibraryAuthorizationStatus.authorized, for: functionName)
        return actions.returnValue(for: functionName) as! MPMediaLibraryAuthorizationStatus
    }

    enum authorizationStatus1: String, _StringRawRepresentable {
        case name = "authorizationStatus1"
    }

    // MARK: - requestAuthorization

    static func requestAuthorization(_ handler: @escaping (MPMediaLibraryAuthorizationStatus) -> Void) {
        let functionName = requestAuthorization2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: handler, forKey: requestAuthorization2.params.handler)
        invocations.record(invocation)
    }

    enum requestAuthorization2: String, _StringRawRepresentable {
        case name = "requestAuthorization2"
        enum params: String, _StringRawRepresentable {
            case handler = "requestAuthorization(_handler:@escaping(MPMediaLibraryAuthorizationStatus)->Void).handler"
        }
    }
}

class MockMediaQuery: NSObject, MediaQueryable {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - songs

    static func songs() -> MPMediaQuery {
        let functionName = songs1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as! MPMediaQuery
    }

    enum songs1: String, _StringRawRepresentable {
        case name = "songs1"
    }
}

class MockMusicInterruptionHandler: NSObject, MusicInterruptionHandling {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - setIsPlaying

    func setIsPlaying(_ isPlaying: Bool) {
        let functionName = setIsPlaying1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: isPlaying, forKey: setIsPlaying1.params.isPlaying)
        invocations.record(invocation)
    }

    enum setIsPlaying1: String, _StringRawRepresentable {
        case name = "setIsPlaying1"
        enum params: String, _StringRawRepresentable {
            case isPlaying = "setIsPlaying(_isPlaying:Bool).isPlaying"
        }
    }

    // MARK: - setDelegate

    func setDelegate(_ delegate: MusicInterruptionDelegate) {
        let functionName = setDelegate2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: delegate, forKey: setDelegate2.params.delegate)
        invocations.record(invocation)
    }

    enum setDelegate2: String, _StringRawRepresentable {
        case name = "setDelegate2"
        enum params: String, _StringRawRepresentable {
            case delegate = "setDelegate(_delegate:MusicInterruptionDelegate).delegate"
        }
    }
}

class MockMusicService: NSObject, MusicServicing {
    var state: MusicServiceState {
        get { return _state }
        set(value) { _state = value; _stateHistory.append(_Variable(value)) }
    }
    var _state: MusicServiceState!
    var _stateHistory: [_Variable<MusicServiceState?>] = []
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - setDelegate

    func setDelegate(delegate: MusicServiceDelegate) {
        let functionName = setDelegate1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: delegate, forKey: setDelegate1.params.delegate)
        invocations.record(invocation)
    }

    enum setDelegate1: String, _StringRawRepresentable {
        case name = "setDelegate1"
        enum params: String, _StringRawRepresentable {
            case delegate = "setDelegate(delegate:MusicServiceDelegate).delegate"
        }
    }

    // MARK: - setRepeatState

    func setRepeatState(_ repeatState: RepeatState) {
        let functionName = setRepeatState2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: repeatState, forKey: setRepeatState2.params.repeatState)
        invocations.record(invocation)
    }

    enum setRepeatState2: String, _StringRawRepresentable {
        case name = "setRepeatState2"
        enum params: String, _StringRawRepresentable {
            case repeatState = "setRepeatState(_repeatState:RepeatState).repeatState"
        }
    }

    // MARK: - setTime

    func setTime(_ time: TimeInterval) {
        let functionName = setTime3.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: time, forKey: setTime3.params.time)
        invocations.record(invocation)
    }

    enum setTime3: String, _StringRawRepresentable {
        case name = "setTime3"
        enum params: String, _StringRawRepresentable {
            case time = "setTime(_time:TimeInterval).time"
        }
    }

    // MARK: - play

    func play() {
        let functionName = play4.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum play4: String, _StringRawRepresentable {
        case name = "play4"
    }

    // MARK: - stop

    func stop() {
        let functionName = stop5.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum stop5: String, _StringRawRepresentable {
        case name = "stop5"
    }

    // MARK: - pause

    func pause() {
        let functionName = pause6.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum pause6: String, _StringRawRepresentable {
        case name = "pause6"
    }

    // MARK: - previous

    func previous() {
        let functionName = previous7.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum previous7: String, _StringRawRepresentable {
        case name = "previous7"
    }

    // MARK: - next

    func next() {
        let functionName = next8.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum next8: String, _StringRawRepresentable {
        case name = "next8"
    }

    // MARK: - shuffle

    func shuffle() {
        let functionName = shuffle9.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum shuffle9: String, _StringRawRepresentable {
        case name = "shuffle9"
    }

    // MARK: - skip

    func skip() {
        let functionName = skip10.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum skip10: String, _StringRawRepresentable {
        case name = "skip10"
    }
}

class MockNowPlayingInfoCenter: NSObject, NowPlayingInfoCentering {
    var nowPlayingInfo: [String: Any]? {
        get { return _nowPlayingInfo }
        set(value) { _nowPlayingInfo = value; _nowPlayingInfoHistory.append(_Variable(value)) }
    }
    var _nowPlayingInfo: [String: Any]? = [:]
    var _nowPlayingInfoHistory: [_Variable<[String: Any]?>] = []
}

class MockPlayButton: NSObject, PlayButtonable {
    var viewState: PlayButtonViewStating? {
        get { return _viewState }
        set(value) { _viewState = value; _viewStateHistory.append(_Variable(value)) }
    }
    var _viewState: PlayButtonViewStating?
    var _viewStateHistory: [_Variable<PlayButtonViewStating?>] = []
}

class MockPlayerController: NSObject, PlayerControlling {
}

class MockPlayerViewController: NSObject, PlayerViewControlling {
    var viewState: PlayerViewStating? {
        get { return _viewState }
        set(value) { _viewState = value; _viewStateHistory.append(_Variable(value)) }
    }
    var _viewState: PlayerViewStating?
    var _viewStateHistory: [_Variable<PlayerViewStating?>] = []
    var scrubberViewController: ScrubberViewControlling {
        get { return _scrubberViewController }
        set(value) { _scrubberViewController = value; _scrubberViewControllerHistory.append(_Variable(value)) }
    }
    var _scrubberViewController: ScrubberViewControlling! = MockScrubberViewController()
    var _scrubberViewControllerHistory: [_Variable<ScrubberViewControlling?>] = []
    var infoViewController: InfoViewControlling {
        get { return _infoViewController }
        set(value) { _infoViewController = value; _infoViewControllerHistory.append(_Variable(value)) }
    }
    var _infoViewController: InfoViewControlling! = MockInfoViewController()
    var _infoViewControllerHistory: [_Variable<InfoViewControlling?>] = []
    var controlsViewController: ControlsViewControlling {
        get { return _controlsViewController }
        set(value) { _controlsViewController = value; _controlsViewControllerHistory.append(_Variable(value)) }
    }
    var _controlsViewController: ControlsViewControlling! = MockControlsViewController()
    var _controlsViewControllerHistory: [_Variable<ControlsViewControlling?>] = []
}

class MockPlaylist: NSObject, Playlistable {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - create

    func create(shuffled: Bool) -> [MPMediaItem] {
        let functionName = create1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: shuffled, forKey: create1.params.shuffled)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as! [MPMediaItem]
    }

    enum create1: String, _StringRawRepresentable {
        case name = "create1"
        enum params: String, _StringRawRepresentable {
            case shuffled = "create(shuffled:Bool).shuffled"
        }
    }

    // MARK: - find

    func find(ids: [UInt64]) -> [MPMediaItem] {
        let functionName = find2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: ids, forKey: find2.params.ids)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as! [MPMediaItem]
    }

    enum find2: String, _StringRawRepresentable {
        case name = "find2"
        enum params: String, _StringRawRepresentable {
            case ids = "find(ids:[UInt64]).ids"
        }
    }
}

class MockRemote: NSObject, Remoting {
    var state: RemoteState {
        get { return _state }
        set(value) { _state = value; _stateHistory.append(_Variable(value)) }
    }
    var _state: RemoteState!
    var _stateHistory: [_Variable<RemoteState?>] = []
    var togglePlayPause: (() -> Void)? {
        get { return _togglePlayPause }
        set(value) { _togglePlayPause = value; _togglePlayPauseHistory.append(_Variable(value)) }
    }
    var _togglePlayPause: (() -> Void)?
    var _togglePlayPauseHistory: [_Variable<() -> Void?>] = []
    var pause: (() -> Void)? {
        get { return _pause }
        set(value) { _pause = value; _pauseHistory.append(_Variable(value)) }
    }
    var _pause: (() -> Void)?
    var _pauseHistory: [_Variable<() -> Void?>] = []
    var play: (() -> Void)? {
        get { return _play }
        set(value) { _play = value; _playHistory.append(_Variable(value)) }
    }
    var _play: (() -> Void)?
    var _playHistory: [_Variable<() -> Void?>] = []
    var stop: (() -> Void)? {
        get { return _stop }
        set(value) { _stop = value; _stopHistory.append(_Variable(value)) }
    }
    var _stop: (() -> Void)?
    var _stopHistory: [_Variable<() -> Void?>] = []
    var prev: (() -> Void)? {
        get { return _prev }
        set(value) { _prev = value; _prevHistory.append(_Variable(value)) }
    }
    var _prev: (() -> Void)?
    var _prevHistory: [_Variable<() -> Void?>] = []
    var next: (() -> Void)? {
        get { return _next }
        set(value) { _next = value; _nextHistory.append(_Variable(value)) }
    }
    var _next: (() -> Void)?
    var _nextHistory: [_Variable<() -> Void?>] = []
    var seekBackward: ((SeekCommandEvent) -> Void)? {
        get { return _seekBackward }
        set(value) { _seekBackward = value; _seekBackwardHistory.append(_Variable(value)) }
    }
    var _seekBackward: ((SeekCommandEvent) -> Void)?
    var _seekBackwardHistory: [_Variable<(SeekCommandEvent) -> Void?>] = []
    var seekForward: ((SeekCommandEvent) -> Void)? {
        get { return _seekForward }
        set(value) { _seekForward = value; _seekForwardHistory.append(_Variable(value)) }
    }
    var _seekForward: ((SeekCommandEvent) -> Void)?
    var _seekForwardHistory: [_Variable<(SeekCommandEvent) -> Void?>] = []
    var changePlayback: ((ChangePlaybackPositionCommandEvent) -> Void)? {
        get { return _changePlayback }
        set(value) { _changePlayback = value; _changePlaybackHistory.append(_Variable(value)) }
    }
    var _changePlayback: ((ChangePlaybackPositionCommandEvent) -> Void)?
    var _changePlaybackHistory: [_Variable<(ChangePlaybackPositionCommandEvent) -> Void?>] = []
    var repeatMode: ((ChangeRepeatModeCommandEvent) -> Void)? {
        get { return _repeatMode }
        set(value) { _repeatMode = value; _repeatModeHistory.append(_Variable(value)) }
    }
    var _repeatMode: ((ChangeRepeatModeCommandEvent) -> Void)?
    var _repeatModeHistory: [_Variable<(ChangeRepeatModeCommandEvent) -> Void?>] = []
}

class MockRepeatButton: NSObject, RepeatButtonable {
    var viewState: RepeatButtonViewStating? {
        get { return _viewState }
        set(value) { _viewState = value; _viewStateHistory.append(_Variable(value)) }
    }
    var _viewState: RepeatButtonViewStating?
    var _viewStateHistory: [_Variable<RepeatButtonViewStating?>] = []
}

class MockScrubberController: NSObject, ScrubberControlling {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - moveScrubber

    func moveScrubber(percentage: Float) {
        let functionName = moveScrubber1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: percentage, forKey: moveScrubber1.params.percentage)
        invocations.record(invocation)
    }

    enum moveScrubber1: String, _StringRawRepresentable {
        case name = "moveScrubber1"
        enum params: String, _StringRawRepresentable {
            case percentage = "moveScrubber(percentage:Float).percentage"
        }
    }

    // MARK: - setIsUserInteractionEnabled

    func setIsUserInteractionEnabled(_ isEnabled: Bool) {
        let functionName = setIsUserInteractionEnabled2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: isEnabled, forKey: setIsUserInteractionEnabled2.params.isEnabled)
        invocations.record(invocation)
    }

    enum setIsUserInteractionEnabled2: String, _StringRawRepresentable {
        case name = "setIsUserInteractionEnabled2"
        enum params: String, _StringRawRepresentable {
            case isEnabled = "setIsUserInteractionEnabled(_isEnabled:Bool).isEnabled"
        }
    }

    // MARK: - setDelegate

    func setDelegate(_ delegate: ScrubberControllerDelegate) {
        let functionName = setDelegate3.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: delegate, forKey: setDelegate3.params.delegate)
        invocations.record(invocation)
    }

    enum setDelegate3: String, _StringRawRepresentable {
        case name = "setDelegate3"
        enum params: String, _StringRawRepresentable {
            case delegate = "setDelegate(_delegate:ScrubberControllerDelegate).delegate"
        }
    }
}

class MockScrubberViewController: NSObject, ScrubberViewControlling {
    var viewState: ScrubberViewStating? {
        get { return _viewState }
        set(value) { _viewState = value; _viewStateHistory.append(_Variable(value)) }
    }
    var _viewState: ScrubberViewStating?
    var _viewStateHistory: [_Variable<ScrubberViewStating?>] = []
    var view: UIView! {
        get { return _view }
        set(value) { _view = value; _viewHistory.append(_Variable(value)) }
    }
    var _view: UIView! = UIView()
    var _viewHistory: [_Variable<UIView?>] = []
    var barView: UIView! {
        get { return _barView }
        set(value) { _barView = value; _barViewHistory.append(_Variable(value)) }
    }
    var _barView: UIView! = UIView()
    var _barViewHistory: [_Variable<UIView?>] = []
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - setDelegate

    func setDelegate(_ delegate: ScrubberViewDelegate) {
        let functionName = setDelegate1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: delegate, forKey: setDelegate1.params.delegate)
        invocations.record(invocation)
    }

    enum setDelegate1: String, _StringRawRepresentable {
        case name = "setDelegate1"
        enum params: String, _StringRawRepresentable {
            case delegate = "setDelegate(_delegate:ScrubberViewDelegate).delegate"
        }
    }
}

class MockSeekCommandEvent: NSObject, SeekCommandEvent {
    var type: MPSeekCommandEventType {
        get { return _type }
        set(value) { _type = value; _typeHistory.append(_Variable(value)) }
    }
    var _type: MPSeekCommandEventType!
    var _typeHistory: [_Variable<MPSeekCommandEventType?>] = []
}

class MockSeeker: NSObject, Seekable {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - startSeekingWithAction

    func startSeekingWithAction(_ action: SeekAction) {
        let functionName = startSeekingWithAction1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: action, forKey: startSeekingWithAction1.params.action)
        invocations.record(invocation)
    }

    enum startSeekingWithAction1: String, _StringRawRepresentable {
        case name = "startSeekingWithAction1"
        enum params: String, _StringRawRepresentable {
            case action = "startSeekingWithAction(_action:SeekAction).action"
        }
    }

    // MARK: - stopSeeking

    func stopSeeking() {
        let functionName = stopSeeking2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum stopSeeking2: String, _StringRawRepresentable {
        case name = "stopSeeking2"
    }

    // MARK: - setDelegate

    func setDelegate(_ delegate: SeekerDelegate) {
        let functionName = setDelegate3.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: delegate, forKey: setDelegate3.params.delegate)
        invocations.record(invocation)
    }

    enum setDelegate3: String, _StringRawRepresentable {
        case name = "setDelegate3"
        enum params: String, _StringRawRepresentable {
            case delegate = "setDelegate(_delegate:SeekerDelegate).delegate"
        }
    }
}

class MockTrackManager: NSObject, TrackManaging {
    var tracks: [MPMediaItem] {
        get { return _tracks }
        set(value) { _tracks = value; _tracksHistory.append(_Variable(value)) }
    }
    var _tracks: [MPMediaItem]! = []
    var _tracksHistory: [_Variable<[MPMediaItem]?>] = []
    var currentTrack: MPMediaItem {
        get { return _currentTrack }
        set(value) { _currentTrack = value; _currentTrackHistory.append(_Variable(value)) }
    }
    var _currentTrack: MPMediaItem! = .mock
    var _currentTrackHistory: [_Variable<MPMediaItem?>] = []
    var currentTrackIndex: Int {
        get { return _currentTrackIndex }
        set(value) { _currentTrackIndex = value; _currentTrackIndexHistory.append(_Variable(value)) }
    }
    var _currentTrackIndex: Int!
    var _currentTrackIndexHistory: [_Variable<Int?>] = []
    var totalTracks: Int {
        get { return _totalTracks }
        set(value) { _totalTracks = value; _totalTracksHistory.append(_Variable(value)) }
    }
    var _totalTracks: Int!
    var _totalTracksHistory: [_Variable<Int?>] = []
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - loadSavedPlaylist

    func loadSavedPlaylist() {
        let functionName = loadSavedPlaylist1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum loadSavedPlaylist1: String, _StringRawRepresentable {
        case name = "loadSavedPlaylist1"
    }

    // MARK: - loadNewPlaylist

    func loadNewPlaylist(shuffled: Bool) {
        let functionName = loadNewPlaylist2.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: shuffled, forKey: loadNewPlaylist2.params.shuffled)
        invocations.record(invocation)
    }

    enum loadNewPlaylist2: String, _StringRawRepresentable {
        case name = "loadNewPlaylist2"
        enum params: String, _StringRawRepresentable {
            case shuffled = "loadNewPlaylist(shuffled:Bool).shuffled"
        }
    }

    // MARK: - cuePrevious

    func cuePrevious() -> Bool {
        let functionName = cuePrevious3.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as! Bool
    }

    enum cuePrevious3: String, _StringRawRepresentable {
        case name = "cuePrevious3"
    }

    // MARK: - cueNext

    func cueNext() -> Bool {
        let functionName = cueNext4.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as! Bool
    }

    enum cueNext4: String, _StringRawRepresentable {
        case name = "cueNext4"
    }

    // MARK: - cueStart

    func cueStart() {
        let functionName = cueStart5.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum cueStart5: String, _StringRawRepresentable {
        case name = "cueStart5"
    }

    // MARK: - cueEnd

    func cueEnd() {
        let functionName = cueEnd6.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocations.record(invocation)
    }

    enum cueEnd6: String, _StringRawRepresentable {
        case name = "cueEnd6"
    }

    // MARK: - removeTrack

    func removeTrack(atIndex index: Int) {
        let functionName = removeTrack7.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: index, forKey: removeTrack7.params.index)
        invocations.record(invocation)
    }

    enum removeTrack7: String, _StringRawRepresentable {
        case name = "removeTrack7"
        enum params: String, _StringRawRepresentable {
            case index = "removeTrack(atIndexindex:Int).index"
        }
    }
}

class MockURLSession: NSObject, URLSessioning {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - dataTask

    func dataTask(with request: URLRequest,completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let functionName = dataTask1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: request, forKey: dataTask1.params.request)
        invocation.set(parameter: completionHandler, forKey: dataTask1.params.completionHandler)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as! URLSessionDataTask
    }

    enum dataTask1: String, _StringRawRepresentable {
        case name = "dataTask1"
        enum params: String, _StringRawRepresentable {
            case request = "dataTask(withrequest:URLRequest,completionHandler:@escaping(Data?,URLResponse?,Error?)->Void).request"
            case completionHandler = "dataTask(withrequest:URLRequest,completionHandler:@escaping(Data?,URLResponse?,Error?)->Void).completionHandler"
        }
    }
}

class MockUserDefaults: NSObject, UserDefaultable {
    let invocations = _Invocations()
    let actions = _Actions()
    static let invocations = _Invocations()
    static let actions = _Actions()

    // MARK: - object

    func object(forKey defaultName: String) -> Any? {
        let functionName = object1.name
        let invocation = _Invocation(name: functionName.rawValue)
        invocation.set(parameter: defaultName, forKey: object1.params.defaultName)
        invocations.record(invocation)
        return actions.returnValue(for: functionName) as Any
    }

    enum object1: String, _StringRawRepresentable {
        case name = "object1"
        enum params: String, _StringRawRepresentable {
            case defaultName = "object(forKeydefaultName:String).defaultName"
        }
    }

    // MARK: - set

    func set(_ value: Any?, forKey defaultName: String) {
        let functionName = set2.name
        let invocation = _Invocation(name: functionName.rawValue)
        if let value = value {
            invocation.set(parameter: value, forKey: set2.params.value)
        }
        invocation.set(parameter: defaultName, forKey: set2.params.defaultName)
        invocations.record(invocation)
    }

    enum set2: String, _StringRawRepresentable {
        case name = "set2"
        enum params: String, _StringRawRepresentable {
            case value = "set(_value:Any?,forKeydefaultName:String).value"
            case defaultName = "set(_value:Any?,forKeydefaultName:String).defaultName"
        }
    }
}

class MockUserService: NSObject, UserServicing {
    var repeatState: RepeatState? {
        get { return _repeatState }
        set(value) { _repeatState = value; _repeatStateHistory.append(_Variable(value)) }
    }
    var _repeatState: RepeatState?
    var _repeatStateHistory: [_Variable<RepeatState?>] = []
    var currentTrackID: MPMediaEntityPersistentID? {
        get { return _currentTrackID }
        set(value) { _currentTrackID = value; _currentTrackIDHistory.append(_Variable(value)) }
    }
    var _currentTrackID: MPMediaEntityPersistentID?
    var _currentTrackIDHistory: [_Variable<MPMediaEntityPersistentID?>] = []
    var trackIDs: [MPMediaEntityPersistentID]? {
        get { return _trackIDs }
        set(value) { _trackIDs = value; _trackIDsHistory.append(_Variable(value)) }
    }
    var _trackIDs: [MPMediaEntityPersistentID]? = []
    var _trackIDsHistory: [_Variable<[MPMediaEntityPersistentID]?>] = []
}
