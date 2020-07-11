import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func viewController(_ viewController: SearchViewControlling, handleAction action: SearchAction)
}

// sourcery: name = SearchViewController
protocol SearchViewControlling: AnyObject, Mockable {
    var viewState: SearchViewStating? { get set }

    func setDelegate(_ delegate: SearchViewControllerDelegate)
}

final class SearchViewController: UIViewController, SearchViewControlling {
    @IBOutlet private(set) weak var searchBar: UISearchBar!
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var doneButton: UIBarButtonItem!
    private let keyboardNotification = KeyboardNotification()

    private weak var delegate: SearchViewControllerDelegate?
    var viewState: SearchViewStating? {
        didSet { _ = viewState.map(bind) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.searchViewTitle
        keyboardNotification.delegate = self
        searchBar.becomeFirstResponder()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 1.0))
        tableView.contentInsetAdjustmentBehavior = .never
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        keyboardNotification.setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        keyboardNotification.tearDown()
    }

    func setDelegate(_ delegate: SearchViewControllerDelegate) {
        self.delegate = delegate
    }

    // MARK: - private

    private func bind(_ viewState: SearchViewStating) {
        guard isViewLoaded else { return }
        tableView.reloadData()
    }

    // MARK: - actions

    @IBAction private func donePressed(_ button: UIBarButtonItem) {
        delegate?.viewController(self, handleAction: .done)
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewState?.rowHeight ?? 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = viewState?.item(at: indexPath) else { return }
        delegate?.viewController(self, handleAction: .select(item))
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewState?.numberOfRows ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let viewState = viewState?.cellViewState(at: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.reuseIdentifier,
                                                     for: indexPath) as? SearchCell else {
                return UITableViewCell()
        }
        cell.viewState = viewState
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewState?.numberOfSections ?? 0
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.viewController(self, handleAction: .search(searchText))
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.viewController(self, handleAction: .done)
    }
}

// MARK: - KeyboardNotificationDelegate

extension SearchViewController: KeyboardNotificationDelegate {
    func keyboardWithShow(height: CGFloat) {
        tableView.contentInset.bottom = height
    }

    func keyboardWillHide() {
        tableView.contentInset.bottom = 0
    }
}
