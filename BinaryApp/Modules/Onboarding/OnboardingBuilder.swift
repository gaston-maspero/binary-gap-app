import UIKit

protocol OnboardingBuilding {
    func build() -> UIViewController
}

final class OnboardingBuilder: OnboardingBuilding {

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func build() -> UIViewController {
        let presenter = OnboardingPresenter(
            onboardingState: container.onboardingState,
            haptics: container.haptics
        )
        let viewController = OnboardingViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
