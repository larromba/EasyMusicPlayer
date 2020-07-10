import Foundation
import Logging

protocol DurationDelegate: AnyObject {
    func duration(_ duration: Duration, didUpdateTime time: TimeInterval)
}

final class Duration {
    var value: TimeInterval {
        guard let analysisInformation = analysisInformation else { return _value }
        // silence is music too, but end silences longer than 5 seconds are painful, so shorten duration
        if analysisInformation.durationOfEndSilence > 5 {
            return analysisInformation.durationWithoutEndSilence
        } else {
            return analysisInformation.duration
        }
    }
    private var _value: TimeInterval
    private var analysisInformation: AudioAnalysisInformation?
    private weak var delegate: DurationDelegate?

    init(_ value: TimeInterval, url: URL?, delegate: DurationDelegate?) {
        _value = value
        self.delegate = delegate

        // AudioAnalysisInformation is quite time consuming, so done on background so doesn't block main thread.
        // [weak self] so audioPlayer is released without waiting.
        // this is better for memory when quickly skipping big files
        DispatchQueue.main.async { [weak self] in
            do {
                guard let delegate = self?.delegate, let url = url else {
                    logWarning("URL or DurationDelegate are nil so won't load AudioAnalysisInformation")
                    return
                }
                self?.analysisInformation = try AudioAnalysisInformation(contentsOf: url)

                // late self check, in case Duration is deallocated before AudioAnalysisInformation is finished
                guard let self = self, Int(self.value) != Int(value) else { return }
                delegate.duration(self, didUpdateTime: self.value)
            } catch {
                logError(error.localizedDescription)
            }
        }
    }
}
