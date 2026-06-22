import UIKit

protocol HistoryBuilding {
    func build() -> UIViewController
}

final class HistoryBuilder: HistoryBuilding {

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func build() -> UIViewController {
        let interactor = HistoryInteractor(historyStore: container.historyStore)
        let router = HistoryRouter()
        let presenter = HistoryPresenter(
            interactor: interactor,
            router: router,
            haptics: container.haptics
        )
        let viewController = HistoryViewController(presenter: presenter)
        presenter.view = viewController
        router.sourceViewController = viewController
        return viewController
    }
}
