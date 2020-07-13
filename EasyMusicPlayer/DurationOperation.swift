import BaseOperation
import Foundation
import Logging

final class DurationOperation: BaseOperation {
    let track: Track
    let completion: (Track) -> Void

    init(track: Track, completion: @escaping (Track) -> Void) {
        self.track = track
        self.completion = completion
    }

    override func execute() {
        do {
            guard let url = track.url else {
                logError("did finish DurationOperation - no url")
                finish()
                return
            }
            let information = try AudioAnalysisInformation(contentsOf: url)
            guard information.durationOfEndSilence > 5 else {
                logError("did finish DurationOperation - no silence detected")
                finish()
                return
            }
            DispatchQueue.main.async {
                log("did finish DurationOperation")
                self.completion(self.track.copy(duration: information.durationWithoutEndSilence))
                self.finish()
            }
        } catch {
            logError("did finish DurationOperation with error: \(error.localizedDescription)")
            finish()
        }
    }

    override func cancel() {
        super.cancel()
        logWarning("cancelling DurationOperation")
        finish()
    }
}
