import AudioToolbox
import AVFoundation

struct AudioAnalysisInformation {
    let duration: TimeInterval
    let durationOfEndSilence: TimeInterval
    let durationWithoutEndSilence: TimeInterval

    init(contentsOf url: URL) throws {
        let audioFile = try AVAudioFile(forReading: url)
        let frameCount = UInt32(audioFile.length)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount)!
        try audioFile.read(into: buffer, frameCount: frameCount)
        var index = 0
        for i in stride(from: frameCount, to: 0, by: -1) {
            if buffer.floatChannelData?.pointee[Int(i)] != 0 {
                index = Int(i)
                break
            }
        }
        duration = Double(frameCount) / audioFile.fileFormat.sampleRate
        durationOfEndSilence = Double(Int(frameCount) - index) / audioFile.fileFormat.sampleRate
        durationWithoutEndSilence = (duration - durationOfEndSilence) + 2.0 // 2 seconds is a nice reflection time
    }
}
