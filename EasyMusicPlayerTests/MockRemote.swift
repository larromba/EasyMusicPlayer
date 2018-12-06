@testable import EasyMusic
import Foundation
import MediaPlayer

// MARK: - MPRemoteCommand

extension MPRemoteCommand {
    static var mock: MPRemoteCommand {
        return MockRemoteCommand()
    }

    static func mockSeek(_ seekTime: TimeInterval) -> MPRemoteCommand {
        return MockSeekRemoteCommand(seekTime: seekTime)
    }
}

final class MockRemoteCommand: MPRemoteCommand {
    var target: Any?
    var action: Selector?

    override func addTarget(_ target: Any, action: Selector) {
        self.target = target
        self.action = action
    }

    func fire() {
        guard let target = target, let action = action else {
            assertionFailure("expected target and action")
            return
        }
        UIApplication.shared.sendAction(action, to: target, from: self, for: nil)
    }

    init(workaround: Int = 0) {} // workaround to not clash with non-overridable super.init()
}

final class MockSeekRemoteCommand: MPRemoteCommand {
    var target: Any?
    var action: Selector?
    let seekTime: TimeInterval

    override func addTarget(_ target: Any, action: Selector) {
        self.target = target
        self.action = action
    }

    func fire() {
        guard let target = target, let action = action else {
            assertionFailure("expected target and action")
            return
        }
        msgSend(target: target, action: action, object: MockSeekCommandEvent(type: .beginSeeking))
        DispatchQueue.main.asyncAfter(deadline: .now() + seekTime) {
            msgSend(target: target, action: action, object: MockSeekCommandEvent(type: .endSeeking))
        }
    }

    init(seekTime: TimeInterval) {
        self.seekTime = seekTime
    }
}

final class MockSeekCommandEvent: SeekCommandEvent {
    let type: MPSeekCommandEventType

    init(type: MPSeekCommandEventType) {
        self.type = type
    }
}

// MARK: - MockChangePlaybackPositionCommand

extension MPChangePlaybackPositionCommand {
    static func mockPlayback(_ time: TimeInterval) -> MockChangePlaybackPositionCommand {
        return MockChangePlaybackPositionCommand(time: time)
    }
}

final class MockChangePlaybackPositionCommand: MPChangePlaybackPositionCommand {
    var target: Any?
    var action: Selector?
    let event: MockChangePlaybackPositionCommandEvent

    override func addTarget(_ target: Any, action: Selector) {
        self.target = target
        self.action = action
    }

    func fire() {
        guard let target = target, let action = action else {
            assertionFailure("expected target and action")
            return
        }
        msgSend(target: target, action: action, object: event)
    }

    init(time: TimeInterval) {
        event = MockChangePlaybackPositionCommandEvent(time: time)
    }
}

final class MockChangePlaybackPositionCommandEvent: ChangePlaybackPositionCommandEvent {
    let positionTime: TimeInterval

    init(time: TimeInterval) {
        positionTime = time
    }
}
