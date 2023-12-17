import SwiftUI

struct ScrubberView: View {
    @StateObject var viewModel: ScrubberViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // invisible area to detect the drag
                Rectangle()
                    .foregroundColor(.scrubberBackground)
                    .opacity(0.01)
                    .frame(maxWidth: .infinity)
                    .gesture(drag)
                    .disabled(viewModel.isDisabled)
                    .accessibilityLabel("Scrubber")

                // the scrubber
                Rectangle()
                    .foregroundColor(.scrubber)
                    .frame(width: viewModel.width)
                    .opacity(viewModel.opacity)
            }
            .onAppear() {
                viewModel.maxWidth = geometry.size.width
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged {
                viewModel.updateDrag($0)
            }
            .onEnded { gesture in
                withAnimation(.easeOut(duration: 0.5)) {
                    viewModel.finishDrag(gesture)
                }
            }
    }
}

//#Preview {
//    VStack {
//        Spacer()
//            .frame(height: 50)
//        ScrubberView(viewModel: ScrubberViewModel(musicPlayer: MusicPlayer()))
//            .frame(maxWidth: .infinity)
//            .frame(height: 200)
//            .background(.white)
//        Spacer()
//    }
//    .background(.black)
//}
