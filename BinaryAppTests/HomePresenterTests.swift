import Testing
import Foundation
@testable import BinaryApp

@MainActor
struct HomePresenterTests {

    @Test("View receives the static view model on viewIsReady")
    func renders_static_view_model() {
        let view = SpyHomeView()
        let presenter = makePresenter(view: view)
        presenter.viewIsReady()
        #expect(view.lastViewModel != nil)
        #expect(view.calculateEnabledLog == [false])
    }

    @Test("Disables calculate button while input is empty")
    func empty_input_disables_button() {
        let view = SpyHomeView()
        let presenter = makePresenter(view: view)
        presenter.viewIsReady()
        presenter.didChangeInput("")
        #expect(view.calculateEnabledLog.last == false)
        #expect(view.lastValidationMessage == nil)
    }

    @Test("Shows validation message for non-numeric input")
    func non_numeric_input_shows_error() {
        let view = SpyHomeView()
        let presenter = makePresenter(view: view)
        presenter.viewIsReady()
        presenter.didChangeInput("abc")
        #expect(view.lastValidationMessage != nil)
        #expect(view.calculateEnabledLog.last == false)
    }

    @Test("Shows validation message for zero")
    func zero_input_shows_error() {
        let view = SpyHomeView()
        let presenter = makePresenter(view: view)
        presenter.viewIsReady()
        presenter.didChangeInput("0")
        #expect(view.lastValidationMessage != nil)
        #expect(view.calculateEnabledLog.last == false)
    }

    @Test("Enables calculate button for a positive integer")
    func positive_integer_enables_button() {
        let view = SpyHomeView()
        let presenter = makePresenter(view: view)
        presenter.viewIsReady()
        presenter.didChangeInput("529")
        #expect(view.calculateEnabledLog.last == true)
        #expect(view.lastValidationMessage == nil)
    }

    @Test("Calculate flows through the interactor and renders the result")
    func calculate_renders_result() {
        let view = SpyHomeView()
        let interactor = SpyHomeInteractor()
        let presenter = makePresenter(view: view, interactor: interactor)
        presenter.viewIsReady()
        presenter.didChangeInput("529")
        presenter.didTapCalculate()

        #expect(interactor.calculatedValues == [529])
        #expect(interactor.savedCalculations.count == 1)
        #expect(view.lastResult?.gapText == "4")
    }

    @Test("Tapping calculate without a valid value warns the user")
    func calculate_without_valid_input_warns() {
        let view = SpyHomeView()
        let presenter = makePresenter(view: view)
        presenter.viewIsReady()
        presenter.didTapCalculate()
        #expect(view.lastValidationMessage != nil)
    }

    @Test("Recent items are refreshed after a calculation")
    func recents_refresh_after_calculation() {
        let view = SpyHomeView()
        let interactor = SpyHomeInteractor()
        let presenter = makePresenter(view: view, interactor: interactor)
        presenter.viewIsReady()
        presenter.didChangeInput("5")
        presenter.didTapCalculate()
        #expect(view.lastRecentItems?.isEmpty == false)
    }

    @Test("Selecting a recent item displays the cached result")
    func selecting_recent_item_displays_result() {
        let view = SpyHomeView()
        let interactor = SpyHomeInteractor()
        let cached = BinaryCalculation(
            value: 1041,
            binaryRepresentation: "10000010001",
            binaryGap: 5
        )
        interactor.lookupTable[cached.id] = cached
        let presenter = makePresenter(view: view, interactor: interactor)
        presenter.viewIsReady()
        presenter.didSelectRecent(itemID: cached.id)
        #expect(view.lastResult?.gapText == "5")
    }

    @Test("View all routes through the router")
    func tapping_view_all_invokes_router() {
        let view = SpyHomeView()
        let router = SpyHomeRouter()
        let presenter = makePresenter(view: view, router: router)
        presenter.viewIsReady()
        presenter.didTapShowFullHistory()
        #expect(router.presentHistoryCount == 1)
    }

    @Test("Help routes through the router")
    func tapping_help_invokes_router() {
        let view = SpyHomeView()
        let router = SpyHomeRouter()
        let presenter = makePresenter(view: view, router: router)
        presenter.viewIsReady()
        presenter.didTapShowHelp()
        #expect(router.presentOnboardingCount == 1)
    }

    // MARK: - Factory

    private func makePresenter(
        view: SpyHomeView,
        interactor: HomeInteractorInput = SpyHomeInteractor(),
        router: HomeRouting = SpyHomeRouter(),
        haptics: HapticsFeedbackProviding = SpyHaptics()
    ) -> HomePresenter {
        let presenter = HomePresenter(
            interactor: interactor,
            router: router,
            haptics: haptics
        )
        presenter.view = view
        return presenter
    }
}

// MARK: - Doubles

@MainActor
private final class SpyHomeView: HomeViewInput {
    var lastViewModel: HomeViewModel?
    var lastResult: HomeResultViewModel?
    var lastValidationMessage: String?
    var lastRecentItems: [HomeRecentItemViewModel]?
    var calculateEnabledLog: [Bool] = []

    func render(_ viewModel: HomeViewModel) { lastViewModel = viewModel }
    func display(result: HomeResultViewModel, animated: Bool) { lastResult = result }
    func clearResult() { lastResult = nil }
    func displayValidationMessage(_ message: String?) { lastValidationMessage = message }
    func display(recentCalculations: [HomeRecentItemViewModel]) { lastRecentItems = recentCalculations }
    func setCalculateEnabled(_ isEnabled: Bool) { calculateEnabledLog.append(isEnabled) }
}

private final class SpyHomeInteractor: HomeInteractorInput {
    var calculatedValues: [Int] = []
    var savedCalculations: [BinaryCalculation] = []
    var fetchedRecentLimits: [Int] = []
    var lookupTable: [UUID: BinaryCalculation] = [:]

    func performCalculation(forValue value: Int) -> BinaryCalculation {
        calculatedValues.append(value)
        return BinaryGapCalculator().calculate(for: value)
    }

    func saveToHistory(_ calculation: BinaryCalculation) {
        savedCalculations.append(calculation)
    }

    func fetchRecentCalculations(limit: Int) -> [BinaryCalculation] {
        fetchedRecentLimits.append(limit)
        return savedCalculations.prefix(limit).map { $0 }
    }

    func fetchCalculation(id: UUID) -> BinaryCalculation? {
        lookupTable[id]
    }
}

private final class SpyHomeRouter: HomeRouting {
    var presentHistoryCount = 0
    var presentOnboardingCount = 0
    func presentHistory() { presentHistoryCount += 1 }
    func presentOnboarding() { presentOnboardingCount += 1 }
}

private final class SpyHaptics: HapticsFeedbackProviding {
    var events: [HapticEvent] = []
    func prepare() {}
    func emit(_ event: HapticEvent) { events.append(event) }
}
