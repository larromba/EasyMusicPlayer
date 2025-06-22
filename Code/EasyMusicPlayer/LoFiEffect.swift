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
        let lowCut = eq.bands[0]
        lowCut.filterType = .lowShelf
        lowCut.frequency = 100
        lowCut.gain = 3
        lowCut.bypass = false

        let lowMidBoost = eq.bands[1]
        lowMidBoost.filterType = .parametric
        lowMidBoost.frequency = 400
        lowMidBoost.bandwidth = 1.0
        lowMidBoost.gain = 2
        lowMidBoost.bypass = false

        let highCut = eq.bands[2]
        highCut.filterType = .resonantLowPass
        highCut.frequency = 6000
        highCut.bandwidth = 0.5
        highCut.bypass = false
    }

    private func setupDistortion() {
        distortion.loadFactoryPreset(.speechWaves)
        distortion.preGain = -6
        distortion.wetDryMix = 25
    }

    private func setupReverb() {
        reverb.loadFactoryPreset(.mediumRoom)
        reverb.wetDryMix = 20
    }

    private func setupVarispeed() {
        varispeed.rate = 0.92
    }
}
