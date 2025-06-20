import AVFoundation

final class LoFiEffect: Effect {
    var isEnabled: Bool {
        get {
            !eq.bypass
        }
        set {
            eq.bypass = !newValue
            distortion.bypass = !newValue
            reverb.bypass = !newValue
            varispeed.bypass = !newValue
        }
    }
    var lastNode: AVAudioNode {
        varispeed
    }

    private let eq = AVAudioUnitEQ(numberOfBands: 3)
    private let distortion = AVAudioUnitDistortion()
    private let reverb = AVAudioUnitReverb()
    private let varispeed = AVAudioUnitVarispeed()

    init() {
        setup()
    }

    func attach(to engine: AVAudioEngine) {
        engine.attach(eq)
        engine.attach(distortion)
        engine.attach(reverb)
        engine.attach(varispeed)
    }

    func connect(engine: AVAudioEngine, to audioUnit: AVAudioNode, format: AVAudioFormat?) {
        engine.connect(audioUnit, to: eq, format: format)
        engine.connect(eq, to: distortion, format: format)
        engine.connect(distortion, to: reverb, format: format)
        engine.connect(reverb, to: varispeed, format: format)
    }

    private func setup() {
        setupEQ()
        setupDistortion()
        setupReverb()
        setupVarispeed()
    }

    private func setupEQ() {
        let lowBoost = eq.bands[0]
        lowBoost.filterType = .parametric
        lowBoost.frequency = 100
        lowBoost.bandwidth = 0.75
        lowBoost.gain = 5
        lowBoost.bypass = false

        let midBoost = eq.bands[1]
        midBoost.filterType = .parametric
        midBoost.frequency = 400
        midBoost.bandwidth = 1.0
        midBoost.gain = 2
        midBoost.bypass = false

        let resonantHighCut = eq.bands[2]
        resonantHighCut.filterType = .resonantLowPass
        resonantHighCut.frequency = 6000
        resonantHighCut.bandwidth = 0.5
        resonantHighCut.bypass = false
    }

    private func setupDistortion() {
        distortion.loadFactoryPreset(.speechWaves)
        distortion.preGain = -6
        distortion.wetDryMix = 35
    }

    private func setupReverb() {
        reverb.loadFactoryPreset(.mediumRoom)
        reverb.wetDryMix = 30
    }

    private func setupVarispeed() {
        varispeed.rate = 0.92
    }
}
