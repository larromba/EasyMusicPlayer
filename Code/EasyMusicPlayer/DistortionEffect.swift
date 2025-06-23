import AVFoundation

final class DistortionEffect: Effect {
    var isEnabled: Bool {
        get {
            !eq.bypass
        }
        set {
            eq.bypass = !newValue
            distortion.bypass = !newValue
            reverb.bypass = !newValue
        }
    }
    var lastNode: AVAudioNode {
        reverb
    }

    private let eq = AVAudioUnitEQ(numberOfBands: 3)
    private let distortion = AVAudioUnitDistortion()
    private let reverb = AVAudioUnitReverb()

    init() {
        setup()
    }

    func attach(to engine: AVAudioEngine) {
        engine.attach(eq)
        engine.attach(distortion)
        engine.attach(reverb)
    }

    func connect(engine: AVAudioEngine, to audioUnit: AVAudioNode, format: AVAudioFormat?) {
        engine.connect(audioUnit, to: eq, format: format)
        engine.connect(eq, to: distortion, format: format)
        engine.connect(distortion, to: reverb, format: format)
    }

    private func setupEQ() {
        let lowCut = eq.bands[0]
        lowCut.filterType = .resonantLowShelf
        lowCut.frequency = 150
        lowCut.bandwidth = 1.0
        lowCut.gain = 3
        lowCut.bypass = false

        let midBoost = eq.bands[1]
        midBoost.filterType = .parametric
        midBoost.frequency = 800
        midBoost.bandwidth = 1.0
        midBoost.gain = 2
        midBoost.bypass = false

        let highCut = eq.bands[2]
        highCut.filterType = .resonantLowPass
        highCut.frequency = 8000
        highCut.bandwidth = 0.5
        highCut.bypass = false
    }

    private func setup() {
        setupEQ()
        setupDistortion()
        setupReverb()
    }

    private func setupDistortion() {
        distortion.loadFactoryPreset(.multiDistortedCubed)
        distortion.preGain = -5
        distortion.wetDryMix = 30
    }

    private func setupReverb() {
        reverb.loadFactoryPreset(.smallRoom)
        reverb.wetDryMix = 5
    }
}
