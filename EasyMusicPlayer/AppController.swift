import Foundation

// sourcery: name = AppController
protocol AppControlling: Mockable {
    // 🦄
}

final class AppController: AppControlling {
    private let router: AppRouting

    init(router: AppRouting) {
        self.router = router
    }
}
