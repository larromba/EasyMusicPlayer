import SwiftUI

extension View {
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
