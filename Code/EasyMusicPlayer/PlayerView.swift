import MediaPlayer
import SwiftUI

struct PlayerView: View {
    @StateObject var viewModel = PlayerViewModel(urlSharer: UIApplication.shared)

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                topSection(geometry: geometry)
                bottomSection(geometry: geometry)
            }
        }
        .sheet(isPresented: $viewModel.openSearch) {
            SearchView(viewModel: viewModel.searchViewModel)
                .padding(.top, 10)
        }
        .alert(isPresented: $viewModel.alert.isPresented) {
            Alert(
                title: Text(viewModel.alert.title),
                message: Text(viewModel.alert.text),
                dismissButton: .cancel(Text(viewModel.alert.buttonTitle))
            )
        }
        .onAppear {
            viewModel.authorize()
        }
    }

    private func topSection(geometry: GeometryProxy) -> some View {
        ZStack {
            InfoView(viewModel: viewModel.infoViewModel)
            ScrubberView(viewModel: viewModel.scrubberViewModel)
        }
        .frame(height: geometry.size.height * 0.34)
    }

    private func bottomSection(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottomTrailing) {
            ControlsView(viewModel: viewModel.controlsViewModel)
            Text(viewModel.version)
                .font(.system(size: 10, weight: .ultraLight))
                .foregroundColor(.versionText)
                .padding(.trailing, 1)
        }
        .frame(height: geometry.size.height * 0.66)
    }
}

//#Preview {
//    PlayerView()
//}
