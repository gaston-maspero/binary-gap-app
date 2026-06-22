import Foundation

// MARK: - View output

protocol OnboardingViewOutput: AnyObject {
    func viewIsReady()
    func didChangeVisiblePage(index: Int)
    func didTapPrimaryAction()
    func didTapSkip()
}

// MARK: - View models

struct OnboardingPageViewModel: Equatable {
    let iconSystemName: String
    let title: String
    let body: String
    let accessibilityLabel: String
}

// MARK: - Presenter

final class OnboardingPresenter {

    weak var view: OnboardingViewInput?

    private let onboardingState: OnboardingStateProviding
    private let haptics: HapticsFeedbackProviding

    private let pages: [OnboardingPageViewModel] = [
        OnboardingPageViewModel(
            iconSystemName: "binary",
            title: "What is a binary gap?",
            body: "The longest run of consecutive zeros that is surrounded by ones in the binary representation of a positive integer.",
            accessibilityLabel: "What is a binary gap? The longest run of consecutive zeros surrounded by ones."
        ),
        OnboardingPageViewModel(
            iconSystemName: "number.square",
            title: "Try a number",
            body: "1041 in binary is 10000010001. The longest gap is five zeros sitting between two ones.",
            accessibilityLabel: "1041 in binary is 10000010001. The longest gap is five zeros sitting between two ones."
        ),
        OnboardingPageViewModel(
            iconSystemName: "sparkles",
            title: "Made for you",
            body: "Calculate instantly, feel a satisfying haptic, browse your history and pick up where you left off.",
            accessibilityLabel: "Calculate instantly, feel a satisfying haptic, and browse your history."
        )
    ]

    private var currentIndex: Int = 0

    init(
        onboardingState: OnboardingStateProviding,
        haptics: HapticsFeedbackProviding
    ) {
        self.onboardingState = onboardingState
        self.haptics = haptics
    }

    private func refreshActionTitle() {
        let isLastPage = currentIndex == pages.count - 1
        view?.setPrimaryActionTitle(isLastPage ? "Get started" : "Next")
    }
}

// MARK: - OnboardingViewOutput

extension OnboardingPresenter: OnboardingViewOutput {

    func viewIsReady() {
        haptics.prepare()
        view?.render(pages: pages)
        view?.setVisiblePage(0, totalPages: pages.count, animated: false)
        refreshActionTitle()
    }

    func didChangeVisiblePage(index: Int) {
        guard pages.indices.contains(index), index != currentIndex else { return }
        currentIndex = index
        view?.setVisiblePage(index, totalPages: pages.count, animated: false)
        haptics.emit(.selection)
        refreshActionTitle()
    }

    func didTapPrimaryAction() {
        let isLastPage = currentIndex == pages.count - 1
        if isLastPage {
            onboardingState.markOnboardingCompleted()
            haptics.emit(.success)
            view?.close()
        } else {
            currentIndex += 1
            view?.setVisiblePage(currentIndex, totalPages: pages.count, animated: true)
            haptics.emit(.selection)
            refreshActionTitle()
        }
    }

    func didTapSkip() {
        onboardingState.markOnboardingCompleted()
        view?.close()
    }
}
