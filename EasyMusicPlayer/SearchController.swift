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
        if let text = text, !text.isEmpty {
            search.find(text) { [weak self] items in
                self?.viewController?.viewState = SearchViewState(items: items)
            }
        } else {
            search.all { [weak self] items in
                self?.viewController?.viewState = SearchViewState(items: items)
            }
        }
    }
}

// MARK: - SearchViewControllerDelegate

extension SearchController: SearchViewControllerDelegate {
    func viewController(_ viewController: SearchViewControlling, handleAction action: SearchAction) {
        switch action {
        case .select(let item): delegate?.controller(self, didSelectItem: item)
        case .search(let text): search(text)
        case .done: delegate?.controller(self, didSelectItem: nil)
        }
    }
}
