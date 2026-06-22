import Foundation

final class DependencyContainer {

    // MARK: - Domain services

    let binaryGapCalculator: BinaryGapCalculating
    let historyStore: CalculationHistoryStoring
    let haptics: HapticsFeedbackProviding
    let onboardingState: OnboardingStateProviding

    // MARK: - Module builders

    private(set) lazy var homeBuilder: HomeBuilding = HomeBuilder(container: self)
    private(set) lazy var historyBuilder: HistoryBuilding = HistoryBuilder(container: self)
    private(set) lazy var onboardingBuilder: OnboardingBuilding = OnboardingBuilder(container: self)

    // MARK: - Init

    init(
        binaryGapCalculator: BinaryGapCalculating = BinaryGapCalculator(),
        historyStore: CalculationHistoryStoring = CalculationHistoryStore(),
        haptics: HapticsFeedbackProviding = HapticsFeedbackProvider(),
        onboardingState: OnboardingStateProviding = OnboardingStateProvider()
    ) {
        self.binaryGapCalculator = binaryGapCalculator
        self.historyStore = historyStore
        self.haptics = haptics
        self.onboardingState = onboardingState
    }
}
