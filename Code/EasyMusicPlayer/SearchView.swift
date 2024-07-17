import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                progressView
                searchResultsView
                notFoundText
            }
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: viewModel.searchPrompt
        )
        .disabled(viewModel.isSearchDisabled)
    }

    private var progressView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.large)
            .tint(.searchProgressView)
            .hidden(viewModel.isProgressViewHidden)
    }

    private var searchResultsView: some View {
        List {
            ForEach(viewModel.tracks) { track in
                VStack(alignment: .leading) {
                    Text(track.resolvedArtist)
                        .font(.system(size: 20, weight: .light))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(track.resolvedTitle)
                        .font(.system(size: 20, weight: .light))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(.black.opacity(0.01)) // hack to make the whole row tappable
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    viewModel.select(track)
                }
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .navigationTitle(viewModel.searchPrompt)
        .navigationBarTitleDisplayMode(.inline)
        .disabled(viewModel.isListDisabled)
    }

    private var notFoundText: some View {
        Text(viewModel.notFoundText)
            .font(.system(size: 40, weight: .light))
            .foregroundColor(.notFoundText)
            .hidden(viewModel.isNotFoundTextHidden)
    }
}

//#Preview {
//    SearchView(viewModel: SearchViewModel(musicPlayer: MusicPlayer(), soundEffects: SoundEffects(), doneAction: {}))
//}
