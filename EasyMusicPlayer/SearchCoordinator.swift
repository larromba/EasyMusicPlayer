import UIKit

// sourcery: name = SearchCoordinator
protocol SearchCoordinating: Mockable {
    func setNavigationController(_ navigationController: UINavigationController)
    func setViewController(_ viewController: SearchViewControlling)
    func setDelegate(_ delegate: SearchCoordinatorDelegate)
    func start()
}

protocol SearchCoordinatorDelegate: AnyObject {
    func coordinator(_ coordinator: SearchCoordinating, didFinishWithItem track: Track?)
}

final class SearchCoordinator: SearchCoordinating {
    private let searchController: SearchControlling
    private weak var navigationController: UINavigationController?
    private weak var delegate: SearchCoordinatorDelegate?

    init(searchController: SearchControlling) {
        self.searchController = searchController
        searchController.setDelegate(self)
    }

    func setNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func setViewController(_ viewController: SearchViewControlling) {
        searchController.setViewController(viewController)
    }

    func setDelegate(_ delegate: SearchCoordinatorDelegate) {
        self.delegate = delegate
    }

    func start() {
        searchController.start()
    }
}

// MARK: - SearchControllerDelegate

extension SearchCoordinator: SearchControllerDelegate {
    func controller(_ controller: SearchControlling, didSelectItem item: Track?) {
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.delegate?.coordinator(self, didFinishWithItem: item)
        })
    }
}
