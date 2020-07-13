import UIKit

// sourcery: name = SearchController
protocol SearchControlling: Mockable {
    func setViewController(_ viewController: SearchViewControlling)
    func setDelegate(_ delegate: SearchControllerDelegate)
    func start()
}

protocol SearchControllerDelegate: AnyObject {
    func controller(_ controller: SearchControlling, didSelectItem item: Track?)
}

final class SearchController: SearchControlling {
    private let search: Searchable
    private weak var viewController: SearchViewControlling?
    private weak var delegate: SearchControllerDelegate?

    init(search: Searchable) {
        self.search = search
    }

    func setViewController(_ viewController: SearchViewControlling) {
        self.viewController = viewController
        viewController.viewState = SearchViewState(items: [], isLoading: false)
        viewController.setDelegate(self)
    }

    func setDelegate(_ delegate: SearchControllerDelegate) {
        self.delegate = delegate
    }

    func start() {
        search(nil)
    }

    // MARK: - private

    private func search(_ text: String?) {
        viewController?.viewState = viewController?.viewState?.copy(isLoading: true)
        if let text = text, !text.isEmpty {
            search.find(text) { [weak self] items in
                self?.viewController?.viewState = SearchViewState(items: items, isLoading: false)
            }
        } else {
            search.all { [weak self] items in
                self?.viewController?.viewState = SearchViewState(items: items, isLoading: false)
            }
        }
    }
}

// MARK: - SearchViewControllerDelegate

extension SearchController: SearchViewControllerDelegate {
    func viewController(_ viewController: SearchViewControlling, handleAction action: SearchAction) {
        switch action {
        case .select(let item):
            delegate?.controller(self, didSelectItem: item)
        case .search(let text):
            viewController.scrollToTop(animated: false)
            search(text)
        case .done:
            delegate?.controller(self, didSelectItem: nil)
        }
    }
}
