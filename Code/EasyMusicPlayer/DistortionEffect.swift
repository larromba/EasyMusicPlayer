import AVFoundation

final class DistortionEffect: Effect {
    var isEnabled: Bool {
        get {
            !eq.bypass
        }
        set {
            eq.bypass = !newValue
            distortion.bypass = !newValue
            wowFlutter.bypass = !newValue
        }
    }
    var lastNode: AVAudioNode {
        wowFlutter
    }

    private let eq = AVAudioUnitEQ(numberOfBands: 3)
    private let distortion = AVAudioUnitDistortion()
    private let wowFlutter = AVAudioUnitDelay()

    init() {
        setup()
    }

    func attach(to engine: AVAudioEngine) {
        engine.attach(eq)
        engine.attach(distortion)
        engine.attach(wowFlutter)
    }

    func connect(engine: AVAudioEngine, to audioUnit: AVAudioNode, format: AVAudioFormat?) {
        engine.connect(audioUnit, to: eq, format: format)
        engine.connect(eq, to: distortion, format: format)
        engine.connect(distortion, to: wowFlutter, format: format)
    }

    private func setupEQ() {
        let lowBoost = eq.bands[0]
        lowBoost.filterType = .parametric
        lowBoost.frequency = 150
        lowBoost.bandwidth = 1.0
        lowBoost.gain = 3
        lowBoost.bypass = false

        let midBoost = eq.bands[1]
        midBoost.filterType = .parametric
        midBoost.frequency = 700
        midBoost.bandwidth = 1.0
        midBoost.gain = 2
        midBoost.bypass = false

        let highCut = eq.bands[2]
        highCut.filterType = .resonantLowPass
        highCut.frequency = 10000
        highCut.bandwidth = 0.5
        highCut.bypass = false
    }

    private func setup() {
        setupEQ()
        setupDistortion()
        setupWowFlutter()
    }

    private func setupDistortion() {
        distortion.loadFactoryPreset(.multiEcho1)
        distortion.preGain = 2.75
        distortion.wetDryMix = 90
    }

    private func setupWowFlutter() {
        wowFlutter.delayTime = 0.01
        wowFlutter.feedback = 10
        wowFlutter.lowPassCutoff = 1000
        wowFlutter.wetDryMix = 15
    }
}
