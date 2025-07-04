import SwiftUI

struct PlayerView: View {
    @StateObject var viewModel = PlayerViewModel()

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
        .alert(for: $viewModel.alert)
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
