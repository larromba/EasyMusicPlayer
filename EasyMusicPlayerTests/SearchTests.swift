@testable import EasyMusic
import MediaPlayer
import XCTest

final class SearchTests: XCTestCase {
    private var navigationController: UINavigationController!
    private var playerViewController: PlayerViewController!
    private var searchViewController: SearchViewController!
    private var env: AppTestEnvironment!

    override func setUp() {
        navigationController = UIStoryboard.search.instantiateInitialViewController() as? UINavigationController
        searchViewController = navigationController.viewControllers[0] as? SearchViewController
        playerViewController = .fromStoryboard()
        env = AppTestEnvironment(playerViewController: playerViewController)
        UIApplication.shared.keyWindow!.rootViewController = playerViewController
        UIView.setAnimationsEnabled(false)
        super.setUp()
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
        // mocks
        env.inject()

        // sut
        playerViewController.present(navigationController, animated: false, completion: nil)

        // test
        waitSync()
        XCTAssertTrue(searchViewController.searchBar.isFirstResponder)
    }

    func test_search_whenOpened_expecLibraryShown() {
        // mocks
        env.inject()
        env.setLibraryTracks()
        simulateRouterAction()

        // sut
        playerViewController.present(navigationController, animated: false, completion: nil)

        // test
        waitSync()
        XCTAssertEqual(searchViewController.numOfRows, library.count)
    }

    func test_search_whenDonePressed_expectSearchClosed() {
        // mocks
        env.inject()
        simulateRouterAction()
        playerViewController.present(navigationController, animated: false, completion: nil)

        // sut
        XCTAssertTrue(searchViewController.doneButton.fire())

        // test
        waitSync()
        XCTAssertNil(playerViewController.presentedViewController)
    }

    func test_search_wheneyboardDonePressed_expectSearchClosed() {
        // mocks
        env.inject()
        simulateRouterAction()
        playerViewController.present(navigationController, animated: false, completion: nil)

        // sut
        let searchBar = searchViewController.searchBar
        searchBar?.delegate?.searchBarSearchButtonClicked?(searchViewController.searchBar)

        // test
        waitSync()
        XCTAssertNil(playerViewController.presentedViewController)
    }

    func test_search_whenTextChanged_expectSearch() {
        // mocks
        env.inject()
        env.setLibraryTracks([
            DummyMediaItem(artist: "alpha", title: "title"),
            DummyMediaItem(artist: "bravo", title: "title"),
            DummyMediaItem(artist: "charlie", title: "title")
        ])
        simulateRouterAction()
        playerViewController.present(navigationController, animated: false, completion: nil)

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
        env.setLibraryTracks()
        simulateRouterAction()
        playerViewController.present(navigationController, animated: false, completion: nil)

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
        env.setLibraryTracks()
        simulateRouterAction()
        playerViewController.present(navigationController, animated: false, completion: nil)

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
        env.setLibraryTracks()
        simulateRouterAction()
        playerViewController.present(navigationController, animated: false, completion: nil)

        // test
        waitSync()
        XCTAssertEqual(searchViewController.numOfRows, library.count)
        XCTAssertTrue(searchViewController.emptyLabel.isHidden)
    }

    func test_result_whenAppears_expectImageWidth() {
        // mocks
        env.inject()
        env.setLibraryTracks([
            DummyMediaItem(artist: "alpha"),
            DummyMediaItem(artist: "bravo", image: nil)
        ])
        simulateRouterAction()

        // sut
        playerViewController.present(navigationController, animated: false, completion: nil)

        // test
        waitSync()
        XCTAssertNotEqual(searchViewController.cell(at: 0)?.imageView?.frame.size.width, 0)
        XCTAssertEqual(searchViewController.cell(at: 1)?.imageView?.frame.size.width, 0)
    }

    func test_search_whenResultSelected_expectSearchClosed() {
        // mocks
        env.inject()
        env.setLibraryTracks()
        simulateRouterAction()
        playerViewController.present(navigationController, animated: false, completion: nil)

        // sut
        waitSync()
        searchViewController.selectRow(0)

        // test
        waitSync()
        XCTAssertNil(playerViewController.presentedViewController)
    }

    func test_result_whenSelected_expectTrackPlays() {
        // mocks
        env.inject()
        env.setLibraryTracks()
        env.setStopped()
        simulateRouterAction()
        playerViewController.present(navigationController, animated: false, completion: nil)

        // sut
        waitSync()
        searchViewController.selectRow(1)

        // test
        waitSync()
        XCTAssertEqual(env.musicService.state.playState, .playing)
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
    }

    func test_result_whenSelectedAndNotFound_expectErrorThrown() {
        // mocks
        env.inject()
        env.setLibraryTracks()
        simulateRouterAction()
        playerViewController.present(navigationController, animated: false, completion: nil)

        // sut
        waitSync()
        env.setLibraryTracks([])
        searchViewController.selectRow(0)

        // test
        waitSync()
        guard let alert = playerViewController.presentedViewController as? UIAlertController else {
            XCTFail("expected UIAlertController")
            return
        }
        XCTAssertEqual(alert.title, "Error")
    }

    // MARK: - private

    private func simulateRouterAction() {
        env.searchCoordinator.setNavigationController(navigationController)
        env.searchCoordinator.setViewController(searchViewController)
        env.searchCoordinator.start()
    }
}

private extension SearchViewController {
    var numOfRows: Int {
        return tableView(tableView, numberOfRowsInSection: 0)
    }

    func title(at row: Int) -> String? {
        let cell = tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as? SearchCell
        return cell?.titleLabel.text
    }

    func cell(at row: Int) -> SearchCell? {
        return tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as? SearchCell
    }

    func selectRow(_ row: Int) {
        tableView(tableView!, didSelectRowAt: IndexPath(row: row, section: 0))
    }
}
