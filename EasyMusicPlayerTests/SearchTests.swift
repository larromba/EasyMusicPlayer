@testable import EasyMusic
import MediaPlayer
import XCTest

final class SearchTests: XCTestCase {
    private var navigationController: UINavigationController!
    private var playerViewController: PlayerViewController!
    private var searchViewController: SearchViewController!
    private var env: AppTestEnvironment!

    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
        navigationController = UIStoryboard.search.instantiateInitialViewController() as? UINavigationController
        searchViewController = navigationController.viewControllers.first as? SearchViewController
        _ = searchViewController.view
        playerViewController = .fromStoryboard()
        env = AppTestEnvironment(playerViewController: playerViewController, alertPresenter: playerViewController)
        UIApplication.shared.keyWindow!.rootViewController = playerViewController
        playerViewController.present(navigationController, animated: false, completion: nil)
    }

    override func tearDown() {
        navigationController = nil
        searchViewController = nil
        playerViewController = nil
        env = nil
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }

    func test_search_whenOpened_expectKeyboardAppears() {
        // test
        waitSync()
        XCTAssertTrue(searchViewController.searchBar.isFirstResponder)
    }

    func test_search_whenOpened_expectLibraryShown() {
        // mocks
        env.inject()
        start()

        // test
        XCTAssertEqual(searchViewController.numOfRows, library.count)
    }

    func test_search_whenDonePressed_expectSearchClosed() {
        // mocks
        env.inject()
        start()

        // sut
        XCTAssertTrue(searchViewController.doneButton.fire())

        // test
        waitSync()
        XCTAssertNil(playerViewController.presentedViewController)
    }

    func test_search_whenKeyboardDonePressed_expectSearchClosed() {
        // mocks
        env.inject()
        start()

        // sut
        let searchBar = searchViewController.searchBar
        searchBar?.delegate?.searchBarSearchButtonClicked?(searchViewController.searchBar)

        // test
        waitSync()
        XCTAssertNil(playerViewController.presentedViewController)
    }

    func test_search_whenTextChanged_expectSearch() {
        // mocks
        let tracks = [
            DummyMediaItem(artist: "alpha", title: "title", id: 0),
            DummyMediaItem(artist: "bravo", title: "title", id: 1),
            DummyMediaItem(artist: "charlie", title: "title", id: 2)
        ]
        env.setSavedTracks(tracks, currentTrack: tracks[0])
        env.inject()
        start()

        // sut
        let searchBar = searchViewController.searchBar!
        searchBar.delegate?.searchBar?(searchBar, textDidChange: "charlie")

        // test
        waitSync()
        XCTAssertEqual(searchViewController.numOfRows, 1)
        XCTAssertEqual(searchViewController.title(at: 0), "charlie\ntitle")
    }

    func test_search_whenNoText_expectRestoresAll() {
        // mocks
        env.inject()
        start()

        // sut
        let searchBar = searchViewController.searchBar!
        searchBar.delegate?.searchBar?(searchBar, textDidChange: "")

        // test
        waitSync()
        XCTAssertEqual(searchViewController.numOfRows, 3)
    }

    func test_search_whenNoResults_expectEmptyTextShown() {
        // mocks
        env.inject()
        start()

        // sut
        let searchBar = searchViewController.searchBar!
        searchBar.delegate?.searchBar?(searchBar, textDidChange: "zzz")

        // test
        waitSync()
        XCTAssertEqual(searchViewController.numOfRows, 0)
        XCTAssertFalse(searchViewController.emptyLabel.isHidden)
    }

    func test_search_whenHasResults_expectEmptyLabelHidden() {
        // mocks
        env.inject()
        start()

        // test
        XCTAssertEqual(searchViewController.numOfRows, library.count)
        XCTAssertTrue(searchViewController.emptyLabel.isHidden)
    }

    func test_result_whenNoImage_expectLongerTitle() {
        // mocks
        let tracks = [
            DummyMediaItem(artist: "alpha alpha alpha alpha alpha alpha", id: 0),
            DummyMediaItem(artist: "blpha blpha blpha blpha blpha blpha", id: 1, image: nil)
        ]
        env.setSavedTracks(tracks, currentTrack: tracks[0])
        env.inject()
        start()

        // test
        XCTAssertLessThan(searchViewController.cell(at: 0)?.titleLabel?.frame.size.width ?? 0.0,
                          searchViewController.cell(at: 1)?.titleLabel?.frame.size.width ?? 0.0)
    }

    func test_search_whenResultSelected_expectSearchClosed() {
        // mocks
        env.inject()
        start()

        // sut
        XCTAssertTrue(searchViewController.selectRow(0))

        // test
        waitSync()
        XCTAssertNil(playerViewController.presentedViewController)
    }

    func test_result_whenSelected_expectTrackPlays() {
        // mocks
        let tracks = [
            DummyMediaItem(artist: "alpha", title: "alpha", id: 0),
            DummyMediaItem(artist: "bravo", title: "bravo", id: 1),
            DummyMediaItem(artist: "charlie", title: "charlie", id: 2)
        ]
        env.setSavedTracks(tracks, currentTrack: tracks[0])
        env.inject()
        start()

        // sut
        XCTAssertTrue(searchViewController.selectRow(1))

        // test
        waitSync()
        XCTAssertEqual(env.musicService.state.playState, .playing)
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
    }

    func test_result_whenSelectedAndNotFound_expectErrorThrown() {
        // mocks
        env.inject()
        start()

        // sut
        searchViewController.viewState = SearchViewState(items: [DummyMediaItem(id: 999)], isLoading: false)
        XCTAssertTrue(searchViewController.selectRow(0))

        // test
        waitSync()
        guard let alert = playerViewController.presentedViewController as? UIAlertController else {
            XCTFail("expected UIAlertController")
            return
        }
        XCTAssertEqual(alert.title, "Error")
        XCTAssertEqual(alert.message, "Couldn't play track")
    }

    func test_search_whenSearchStarted_expectLoadingIndicatorStartsAndTableDisabled() {
        // mocks
        env.inject()
        start()

        // sut
        let searchBar = searchViewController.searchBar!
        searchBar.delegate?.searchBar?(searchBar, textDidChange: " ")

        // sut
        XCTAssertTrue(searchViewController.activityIndicatorView.isAnimating)
        XCTAssertFalse(searchViewController.tableView.isUserInteractionEnabled)
        XCTAssertEqual(searchViewController.tableView.alpha, 0.5)
    }

    func test_search_whenSearchFinished_expectLoadingIndicatorStopsAndTableEnabled() {
        // mocks
        env.inject()
        start()

        // sut
        let searchBar = searchViewController.searchBar!
        searchBar.delegate?.searchBar?(searchBar, textDidChange: " ")

        // sut
        waitSync()
        XCTAssertFalse(searchViewController.activityIndicatorView.isAnimating)
        XCTAssertTrue(searchViewController.tableView.isUserInteractionEnabled)
        XCTAssertEqual(searchViewController.tableView.alpha, 1.0)
    }

    // MARK: - private

    private func start() {
        env.searchCoordinator.setNavigationController(navigationController)
        env.searchCoordinator.setViewController(searchViewController)
        env.searchCoordinator.start()
        #if TRAVIS // for some reason more time is needed on CI
        waitSync(for: 4.0)
        #else
        waitSync()
        #endif
    }
}

// MARK: - SearchViewController

private extension SearchViewController {
    var numOfRows: Int {
        return tableView(tableView, numberOfRowsInSection: 0)
    }

    func title(at row: Int) -> String? {
        guard row < tableView.numberOfRows(inSection: 0) else { return nil }
        let cell = tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as? SearchCell
        return cell?.titleLabel.text
    }

    func cell(at row: Int) -> SearchCell? {
        guard row < tableView.numberOfRows(inSection: 0) else { return nil }
        return tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as? SearchCell
    }

    func selectRow(_ row: Int) -> Bool {
        guard row < tableView.numberOfRows(inSection: 0) else { return false }
        tableView(tableView!, didSelectRowAt: IndexPath(row: row, section: 0))
        return true
    }
}
