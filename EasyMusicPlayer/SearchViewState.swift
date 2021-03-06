import MediaPlayer
import UIKit

protocol SearchViewStating {
    var rowHeight: CGFloat { get }
    var numberOfRows: Int { get }
    var numberOfSections: Int { get }
    var isEmptyLabelHidden: Bool { get }
    var emptyText: String { get }
    var isLoading: Bool { get }

    func item(at indexPath: IndexPath) -> Track
    func cellViewState(at indexPath: IndexPath) -> SearchCellViewStating

    func copy(isLoading: Bool) -> SearchViewState
}

struct SearchViewState: SearchViewStating {
    let rowHeight: CGFloat = 80.0
    var numberOfRows: Int {
        return items.count
    }
    let numberOfSections: Int = 1
    var isEmptyLabelHidden: Bool {
        return !items.isEmpty
    }
    let emptyText: String = L10n.searchViewEmptyText
    let isLoading: Bool
    private let items: [MPMediaItem]

    init(items: [MPMediaItem], isLoading: Bool) {
        self.items = items
        self.isLoading = isLoading
    }

    func item(at indexPath: IndexPath) -> Track {
        return Track(mediaItem: items[indexPath.row])
    }

    func cellViewState(at indexPath: IndexPath) -> SearchCellViewStating {
        let item = Track(mediaItem: items[indexPath.row], artworkSize: CGSize(width: 100, height: 100))
        let title = "\(item.artist)\n\(item.title)"
        return SearchCellViewState(title: title, image: item.artwork)
    }
}

extension SearchViewState {
    func copy(isLoading: Bool) -> SearchViewState {
        return SearchViewState(items: items, isLoading: isLoading)
    }
}
