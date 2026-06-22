import UIKit

protocol HomeBuilding {
    func build() -> UIViewController
}

final class HomeBuilder: HomeBuilding {

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func build() -> UIViewController {
        let interactor = HomeInteractor(
            calculator: container.binaryGapCalculator,
            historyStore: container.historyStore
        )
        let router = HomeRouter(
            historyBuilder: container.historyBuilder,
            onboardingBuilder: container.onboardingBuilder
        )
        let presenter = HomePresenter(
            interactor: interactor,
            router: router,
            haptics: container.haptics
        )
        let viewController = HomeViewController(presenter: presenter)
        presenter.view = viewController
        router.sourceViewController = viewController
        return viewController
    }
}
