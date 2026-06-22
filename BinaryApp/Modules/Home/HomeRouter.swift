import UIKit

protocol HomeRouting: AnyObject {
    func presentHistory()
    func presentOnboarding()
}

final class HomeRouter: HomeRouting {

    weak var sourceViewController: UIViewController?

    private let historyBuilder: HistoryBuilding
    private let onboardingBuilder: OnboardingBuilding

    init(
        historyBuilder: HistoryBuilding,
        onboardingBuilder: OnboardingBuilding
    ) {
        self.historyBuilder = historyBuilder
        self.onboardingBuilder = onboardingBuilder
    }

    func presentHistory() {
        let destination = historyBuilder.build()
        sourceViewController?.navigationController?.pushViewController(destination, animated: true)
    }

    func presentOnboarding() {
        let destination = onboardingBuilder.build()
        destination.modalPresentationStyle = .pageSheet
        if let sheet = destination.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        sourceViewController?.present(destination, animated: true)
    }
}
