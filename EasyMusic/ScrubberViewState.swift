import CoreGraphics
import Foundation

struct ScrubberViewState {
    let isUserInteractionEnabled: Bool
    let barAlpha: CGFloat
    let barWidth: CGFloat
}

extension ScrubberViewState {
    func copy(isUserInteractionEnabled: Bool) -> ScrubberViewState {
        return ScrubberViewState(
            isUserInteractionEnabled: isUserInteractionEnabled,
            barAlpha: barAlpha,
            barWidth: barWidth
        )
    }

    func copy(barAlpha: CGFloat) -> ScrubberViewState {
        return ScrubberViewState(
            isUserInteractionEnabled: isUserInteractionEnabled,
            barAlpha: barAlpha,
            barWidth: barWidth
        )
    }

    func copy(barWidth: CGFloat) -> ScrubberViewState {
        return ScrubberViewState(
            isUserInteractionEnabled: isUserInteractionEnabled,
            barAlpha: barAlpha,
            barWidth: barWidth
        )
    }
}
