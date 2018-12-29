import CoreGraphics
import Foundation

protocol ScrubberViewStating {
    var isUserInteractionEnabled: Bool { get }
    var barAlpha: CGFloat { get }
    var barWidth: CGFloat { get }

    func copy(isUserInteractionEnabled: Bool) -> ScrubberViewStating
    func copy(barAlpha: CGFloat) -> ScrubberViewStating
    func copy(barWidth: CGFloat) -> ScrubberViewStating
}

struct ScrubberViewState: ScrubberViewStating {
    let isUserInteractionEnabled: Bool
    let barAlpha: CGFloat
    let barWidth: CGFloat
}

extension ScrubberViewState {
    func copy(isUserInteractionEnabled: Bool) -> ScrubberViewStating {
        return ScrubberViewState(
            isUserInteractionEnabled: isUserInteractionEnabled,
            barAlpha: barAlpha,
            barWidth: barWidth
        )
    }

    func copy(barAlpha: CGFloat) -> ScrubberViewStating {
        return ScrubberViewState(
            isUserInteractionEnabled: isUserInteractionEnabled,
            barAlpha: barAlpha,
            barWidth: barWidth
        )
    }

    func copy(barWidth: CGFloat) -> ScrubberViewStating {
        return ScrubberViewState(
            isUserInteractionEnabled: isUserInteractionEnabled,
            barAlpha: barAlpha,
            barWidth: barWidth
        )
    }
}
