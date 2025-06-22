import SwiftUI

struct ControlsView: View {
    @StateObject var viewModel: ControlsViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                topButtons
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                middleButtons
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.34)
                bottomButtons
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
            }
        }
    }

    private var topButtons: some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                // FIXME: see comment in AudioEngineAdaptor -> setup()
                #if !targetEnvironment(simulator)
                button(viewModel.lofiButton) {
                    animate(.lofiButton)
                    viewModel.toggleLofi()
                }
                .frame(width: geometry.size.height * 0.5)
                .frame(maxWidth: .infinity)
                .rotationEffect(.degrees(-15))
                #endif

                button(viewModel.stopButton) {
                    animate(.stopButton)
                    viewModel.stop()
                }
                .frame(width: geometry.size.height * 0.6)
                .frame(maxWidth: .infinity)

                // FIXME: see comment in AudioEngineAdaptor -> setup()
                #if !targetEnvironment(simulator)
                button(viewModel.distortionButton) {
                    animate(.distortionButton)
                    viewModel.toggleDistortion()
                }
                .frame(width: geometry.size.height * 0.5)
                .frame(maxWidth: .infinity)
                .rotationEffect(.degrees(15))
                #endif
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.controlsTopRow)
        }
    }

    private var middleButtons: some View {
        GeometryReader { geometry in
            HStack {
                button(viewModel.previousButton) {}
                    .highPriorityGesture(
                        TapGesture().onEnded { _ in
                            guard !viewModel.previousButton.isDisabled else { return }
                            animate(.previousButton)
                            viewModel.previous()
                        }
                    )
                    .simultaneousGesture(startSeekingBackward)
                    .simultaneousGesture(stopSeeking)
                    .frame(width: geometry.size.height * 0.6)
                Spacer()
                button(viewModel.playButton) {}
                    .highPriorityGesture(
                        TapGesture().onEnded { _ in
                            animate(.playButton)
                            viewModel.play()
                        }
                    )
                    .simultaneousGesture(toggle)
                    .frame(width: geometry.size.height * 0.7)
                Spacer()
                button(viewModel.nextButton) {}
                    .highPriorityGesture(
                        TapGesture().onEnded { _ in
                            guard !viewModel.nextButton.isDisabled else { return }
                            animate(.nextButton)
                            viewModel.next()
                        }
                    )
                    .simultaneousGesture(startSeekingForward)
                    .simultaneousGesture(stopSeeking)
                    .frame(width: geometry.size.height * 0.6)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.controlsMiddleRow)
        }
    }

    private var bottomButtons: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    Spacer()
                    button(viewModel.repeatButton) {
                        animate(.repeatButton)
                        viewModel.toggleRepeatMode()
                    }
                    .frame(width: geometry.size.height * 0.35)
                    .padding(.bottom, 10)
                }
                Spacer()
                button(viewModel.shuffleButton) {
                    animate(.shuffleButton)
                    viewModel.shuffle()
                }
                .frame(width: geometry.size.height * 0.6)
                Spacer()
                VStack {
                    Spacer()
                    button(viewModel.searchButton) {
                        animate(.searchButton)
                        viewModel.search()
                    }
                    .frame(width: geometry.size.height * 0.35)
                    .padding(.bottom, 10)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.controlsBottomRow)
        }
    }

    private func button(
        _ button: MusicPlayerControl,
        _ action: @escaping (() -> Void)
    ) -> some View {
        Button(
            action: action,
            label: {
                Image(uiImage: button.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        )
        .rotationEffect(.degrees(button.rotation))
        .scaleEffect(button.scale, anchor: .center)
        .disabled(button.isDisabled)
        .opacity(button.opacity)
        .accessibilityLabel(button.accessibilityLabel)
    }

    // TODO: is there a way to use WritableKeyPath?
    private enum ButtonType {
        case playButton
        case stopButton
        case nextButton
        case previousButton
        case repeatButton
        case searchButton
        case shuffleButton
        case lofiButton
        case distortionButton
    }

    private func animate(_ button: ButtonType) {
        withAnimation(.easeIn(duration: 0.1).speed(0.9), {
            switch button {
            case .playButton: viewModel.playButton.animate()
            case .stopButton: viewModel.stopButton.animate()
            case .nextButton: viewModel.nextButton.animate()
            case .previousButton: viewModel.previousButton.animate()
            case .repeatButton: viewModel.repeatButton.animate()
            case .shuffleButton: viewModel.shuffleButton.animate()
            case .searchButton: viewModel.searchButton.animate()
            case .lofiButton: viewModel.lofiButton.animate()
            case .distortionButton: viewModel.distortionButton.animate()
            }
        }, completion: {
            animateOut(button)
        })
    }

    private func animateOut(_ button: ButtonType) {
        withAnimation(.easeOut(duration: 0.1).speed(0.9), {
            switch button {
            case .playButton: viewModel.playButton.reset()
            case .stopButton: viewModel.stopButton.reset()
            case .nextButton: viewModel.nextButton.reset()
            case .previousButton: viewModel.previousButton.reset()
            case .repeatButton: viewModel.repeatButton.reset()
            case .shuffleButton: viewModel.shuffleButton.reset()
            case .searchButton: viewModel.searchButton.reset()
            case .lofiButton: viewModel.lofiButton.reset()
            case .distortionButton: viewModel.distortionButton.reset()
            }
        })
    }

    private var startSeekingBackward: some Gesture {
        LongPressGesture(minimumDuration: 1, maximumDistance: 20)
            .onEnded { _ in
                viewModel.startSeeking(.backward)
            }
    }

    private var startSeekingForward: some Gesture {
        LongPressGesture(minimumDuration: 1, maximumDistance: 30)
            .onEnded { _ in
                viewModel.startSeeking(.forward)
            }
    }

    private var stopSeeking: some Gesture {
        DragGesture(minimumDistance: 0)
            .onEnded { _ in
                viewModel.stopSeeking()
            }
    }

    private var toggle: some Gesture {
        LongPressGesture(minimumDuration: 5, maximumDistance: 30)
            .onEnded { _ in
                viewModel.toggle()
            }
    }
}

//#Preview {
//    ControlsView(
//        viewModel: ControlsViewModel(
//            musicPlayer: MusicPlayer(),
//            soundEffects: SoundEffects(),
//            searchAction: {})
//    )
//    .frame(height: 500)
//    .frame(maxWidth: .infinity)
//    .background(.black)
//}
