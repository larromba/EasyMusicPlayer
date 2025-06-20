import AVFoundation

/// wrapper around `AVAudioEngine`
/// interface based on `AVAudioPlayer`
/// created with the help of `ChatGPT`
final class AudioEngineAdaptor: AudioPlayer, @unchecked Sendable {
    var isPlaying: Bool {
        playerNode.isPlaying
    }
    var isPaused: Bool {
        !playerNode.isPlaying && seekFrame > 0
    }
    /// current time in seconds
    var currentTime: TimeInterval {
        get {
            guard let nodeTime = playerNode.lastRenderTime,
                  let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
                return Double(seekFrame) / audioFile.processingFormat.sampleRate // last known time
            }
            let playedFrames = max(0, AVAudioFramePosition(playerTime.sampleTime))
            let currentFrame = seekFrame + playedFrames
            let currentTime = Double(currentFrame) / playerTime.sampleRate
            return currentTime
        }
        set {
            let newValue = max(newValue, 0)
            let sampleRate = audioFile.processingFormat.sampleRate
            let totalFrames = audioFile.length
            let newFrame = AVAudioFramePosition(newValue * sampleRate)
            seekFrame = min(newFrame, totalFrames - 1) // don't go past EOF
            seek()
        }
    }
    var duration: TimeInterval {
        guard audioFile.processingFormat.sampleRate > 0 else { return 0 }
        return Double(audioFile.length) / audioFile.processingFormat.sampleRate
    }
    var volume: Float {
        get { playerNode.volume }
        set { playerNode.volume = newValue }
    }
    var isLofiEnabled: Bool {
        lofi.isEnabled
    }
    var isDistortionEnabled: Bool {
        distortion.isEnabled
    }
    var delegate: AudioPlayerDelegate?

    private var currentSeekFrame: AVAudioFramePosition {
        guard let nodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
            return seekFrame // previous seekFrame
        }
        let currentFrame = seekFrame + AVAudioFramePosition(playerTime.sampleTime)
        return currentFrame
    }
    private var isPlaybackFinished: Bool {
        guard let nodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
            return false
        }
        let currentFrame = seekFrame + AVAudioFramePosition(playerTime.sampleTime)
        let framesRemaining = AVAudioFrameCount(audioFile.length - seekFrame)
        let endFrame = seekFrame + AVAudioFramePosition(framesRemaining)
        return currentFrame >= endFrame
    }

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let lofi: Effect = LoFiEffect()
    private let distortion: Effect = DistortionEffect()
    private let mixer = AVAudioMixerNode()
    private let userService = UserService()
    private let audioFile: AVAudioFile
    private var seekFrame: AVAudioFramePosition = 0
    private var didFinishPlaybackTimer: Timer?

    init(contentsOf url: URL) throws {
        self.audioFile = try AVAudioFile(forReading: url)

        setup()
    }

    @discardableResult
    func play() -> Bool {
        do {
            if !engine.isRunning {
                try engine.start()
            }
            if !playerNode.isPlaying {
                guard setPlayhead() else {
                    return false
                }
                playerNode.play()
                setupDidFinishPlaybackTimer()
            }
            return true
        } catch {
            logError("failed to start audio engine: \(error)")
            return false
        }
    }

    func pause() {
        guard playerNode.isPlaying else { return }
        seekFrame = currentSeekFrame
        playerNode.stop()
        tearDownDidFinishPlaybackTimer()
    }

    func stop() {
        playerNode.stop()
        tearDownDidFinishPlaybackTimer()
        seekFrame = 0
    }

    func prepareToPlay() -> Bool {
        setPlayhead()
    }

    func setLoFiEnabled(_ isEnabled: Bool) {
        lofi.isEnabled = isEnabled
    }

    func setDistortionEnabled(_ isEnabled: Bool) {
        distortion.isEnabled = isEnabled
    }

    private func setup() {
        engine.attach(playerNode)

        // FIXME: to hear the audio in the simulator, both fx must be enabled 🤷
        #if targetEnvironment(simulator)
        engine.connect(playerNode, to: engine.mainMixerNode, format: audioFile.processingFormat)
        #else
        engine.attach(lofi)
        engine.attach(distortion)

        engine.connect(playerNode, to: lofi, format: audioFile.processingFormat)
        engine.connect(lofi, to: distortion, format: audioFile.processingFormat)
        engine.connect(distortion, to: engine.mainMixerNode, format: audioFile.processingFormat)
        #endif

        lofi.isEnabled = userService.isLofiEnabled
        distortion.isEnabled = userService.isDistortionEnabled

        do {
            try engine.start()
        } catch {
            logError("failed to start audio engine: \(error)")
        }
    }

    @discardableResult
    private func setPlayhead() -> Bool {
        let remainingFrames = audioFile.length - seekFrame
        guard remainingFrames > 0 else {
            delegate?.audioPlayerDecodeErrorDidOccur(self, error: AudioError.playhead)
            return false
        }
        playerNode.scheduleSegment(
            audioFile,
            startingFrame: seekFrame,
            frameCount: AVAudioFrameCount(remainingFrames),
            at: nil,
            completionHandler: nil
        )
        return true
    }

    private func seek() {
        guard playerNode.isPlaying else { return }
        playerNode.stop()
        play()
    }

    private func setupDidFinishPlaybackTimer() {
        tearDownDidFinishPlaybackTimer()
        didFinishPlaybackTimer = .scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self, isPlaybackFinished else { return }
            stop()
            delegate?.audioPlayerDidFinishPlaying(self, successfully: true)
        }
    }

    private func tearDownDidFinishPlaybackTimer() {
        didFinishPlaybackTimer?.invalidate()
        didFinishPlaybackTimer = nil
    }
}

private extension AudioEngineAdaptor {
    enum AudioError: Error {
        case playhead
    }
}

private extension AVAudioEngine {
    /// attach an effect
    func attach(_ node: Effect) {
        node.attach(to: self)
    }

    /// connect a node to an effect
    func connect(_ node1: AVAudioNode, to node2: Effect, format: AVAudioFormat?) {
        node2.connect(engine: self, to: node1, format: format)
    }

    /// connect an effect to a node
    func connect(_ node1: Effect, to node2: AVAudioNode, format: AVAudioFormat?) {
        connect(node1.lastNode, to: node2, format: format)
    }

    /// connect an effect to an effect
    func connect(_ node1: Effect, to node2: Effect, format: AVAudioFormat?) {
        node2.connect(engine: self, to: node1.lastNode, format: format)
    }
}
