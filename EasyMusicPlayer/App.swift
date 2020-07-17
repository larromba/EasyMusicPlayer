import Foundation

// sourcery: name = AppController
protocol Appable: Mockable {
    // 🦄
}

final class App: Appable {
    private let router: AppRouting

    init(router: AppRouting) {
        self.router = router
    }
}
