import Foundation

// MARK: - View output

protocol HomeViewOutput: AnyObject {
    func viewIsReady()
    func viewWillAppear()
    func didChangeInput(_ rawValue: String?)
    func didTapCalculate()
    func didTapShowFullHistory()
    func didTapShowHelp()
    func didSelectRecent(itemID: UUID)
}

// MARK: - View models

struct HomeViewModel: Equatable {
    let title: String
    let subtitle: String
    let inputPlaceholder: String
    let inputAccessibilityHint: String
    let calculateTitle: String
    let recentTitle: String
    let emptyRecentMessage: String
    let viewAllTitle: String
}

struct HomeResultViewModel: Equatable {
    let valueText: String
    let binaryRepresentation: BinaryRepresentationView.Configuration
    let gapText: String
    let summary: String
    let accessibilitySummary: String
}

struct HomeRecentItemViewModel: Equatable {
    let id: UUID
    let title: String
    let binarySnippet: String
    let gapDescription: String
    let accessibilityLabel: String
}

// MARK: - Presenter

final class HomePresenter {

    // MARK: - VIPER references

    weak var view: HomeViewInput?
    private let interactor: HomeInteractorInput
    private let router: HomeRouting
    private let haptics: HapticsFeedbackProviding

    // MARK: - State

    private var pendingValue: Int?
    private let recentLimit = 3

    // MARK: - Init

    init(
        interactor: HomeInteractorInput,
        router: HomeRouting,
        haptics: HapticsFeedbackProviding
    ) {
        self.interactor = interactor
        self.router = router
        self.haptics = haptics
    }
}

// MARK: - HomeViewOutput

extension HomePresenter: HomeViewOutput {

    func viewIsReady() {
        view?.render(Self.makeStaticViewModel())
        view?.setCalculateEnabled(false)
        haptics.prepare()
    }

    func viewWillAppear() {
        refreshRecent()
    }

    func didChangeInput(_ rawValue: String?) {
        let parseResult = InputParser.parse(rawValue)
        switch parseResult {
        case .empty:
            pendingValue = nil
            view?.displayValidationMessage(nil)
            view?.setCalculateEnabled(false)
        case .invalid(let message):
            pendingValue = nil
            view?.displayValidationMessage(message)
            view?.setCalculateEnabled(false)
        case .valid(let value):
            pendingValue = value
            view?.displayValidationMessage(nil)
            view?.setCalculateEnabled(true)
        }
    }

    func didTapCalculate() {
        guard let value = pendingValue else {
            haptics.emit(.warning)
            view?.displayValidationMessage(Copy.invalidNumber)
            return
        }

        let calculation = interactor.performCalculation(forValue: value)
        interactor.saveToHistory(calculation)
        haptics.emit(calculation.binaryGap > 0 ? .success : .selection)
        view?.display(result: ResultFormatter.viewModel(from: calculation), animated: true)
        refreshRecent()
    }

    func didTapShowFullHistory() {
        haptics.emit(.selection)
        router.presentHistory()
    }

    func didTapShowHelp() {
        haptics.emit(.selection)
        router.presentOnboarding()
    }

    func didSelectRecent(itemID: UUID) {
        guard let calculation = interactor.fetchCalculation(id: itemID) else { return }
        haptics.emit(.selection)
        view?.display(result: ResultFormatter.viewModel(from: calculation), animated: true)
    }
}

// MARK: - Helpers

private extension HomePresenter {

    func refreshRecent() {
        let recents = interactor.fetchRecentCalculations(limit: recentLimit)
        let items = recents.map(RecentItemFormatter.viewModel(from:))
        view?.display(recentCalculations: items)
    }

    static func makeStaticViewModel() -> HomeViewModel {
        HomeViewModel(
            title: Copy.title,
            subtitle: Copy.subtitle,
            inputPlaceholder: Copy.inputPlaceholder,
            inputAccessibilityHint: Copy.inputAccessibilityHint,
            calculateTitle: Copy.calculateTitle,
            recentTitle: Copy.recentTitle,
            emptyRecentMessage: Copy.emptyRecentMessage,
            viewAllTitle: Copy.viewAllTitle
        )
    }
}

// MARK: - Copy

private enum Copy {
    static let title = "Binary Gap"
    static let subtitle = "Enter a positive integer to find the longest run of zeros surrounded by ones."
    static let inputPlaceholder = "e.g. 1041"
    static let inputAccessibilityHint = "Enter a positive integer between 1 and the maximum supported value"
    static let calculateTitle = "Calculate"
    static let recentTitle = "Recent"
    static let emptyRecentMessage = "Your recent results will appear here."
    static let viewAllTitle = "View all"
    static let invalidNumber = "Please enter a positive integer."
}

// MARK: - Input parsing

enum HomeInputParseResult: Equatable {
    case empty
    case valid(Int)
    case invalid(String)
}

enum InputParser {

    static let maximumValue: Int = .max

    static func parse(_ rawValue: String?) -> HomeInputParseResult {
        let trimmed = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return .empty }
        guard CharacterSet(charactersIn: trimmed).isSubset(of: .decimalDigits) else {
            return .invalid("Only digits are allowed.")
        }
        guard let value = Int(trimmed) else {
            return .invalid("That number is too large.")
        }
        guard value > 0 else {
            return .invalid("Number must be greater than zero.")
        }
        return .valid(value)
    }
}

// MARK: - Formatting

enum ResultFormatter {

    static func viewModel(from calculation: BinaryCalculation) -> HomeResultViewModel {
        let gapRange = longestGapRange(in: calculation.binaryRepresentation)
        let valueText = "Decimal \(calculation.value.formatted())"
        let gapText = "\(calculation.binaryGap)"
        let summary: String
        if calculation.binaryGap == 0 {
            summary = "No binary gap found."
        } else {
            summary = "Longest gap of zeros surrounded by ones."
        }
        let accessibility = "Decimal \(calculation.value), binary \(calculation.binaryRepresentation), longest gap is \(calculation.binaryGap)."
        return HomeResultViewModel(
            valueText: valueText,
            binaryRepresentation: BinaryRepresentationView.Configuration(
                binary: calculation.binaryRepresentation,
                gapRange: gapRange
            ),
            gapText: gapText,
            summary: summary,
            accessibilitySummary: accessibility
        )
    }

    /// Returns the slice of indices (left-to-right) belonging to the longest zero
    /// run that is surrounded by ones. Returns nil when the number contains no gap.
    static func longestGapRange(in binary: String) -> Range<Int>? {
        var bestRange: Range<Int>?
        var bestLength = 0
        var currentStart: Int?
        var hasSeenLeadingOne = false

        for (index, character) in binary.enumerated() {
            if character == "1" {
                if let start = currentStart, hasSeenLeadingOne {
                    let length = index - start
                    if length > bestLength {
                        bestLength = length
                        bestRange = start..<index
                    }
                }
                hasSeenLeadingOne = true
                currentStart = nil
            } else if hasSeenLeadingOne, currentStart == nil {
                currentStart = index
            }
        }
        return bestRange
    }
}

enum RecentItemFormatter {

    private static let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    static func viewModel(from calculation: BinaryCalculation) -> HomeRecentItemViewModel {
        let relativeDate = dateFormatter.localizedString(for: calculation.createdAt, relativeTo: Date())
        let snippet = truncatedBinary(calculation.binaryRepresentation)
        return HomeRecentItemViewModel(
            id: calculation.id,
            title: "\(calculation.value.formatted())",
            binarySnippet: snippet,
            gapDescription: "Gap \(calculation.binaryGap) · \(relativeDate)",
            accessibilityLabel: "Decimal \(calculation.value), longest gap \(calculation.binaryGap), \(relativeDate)."
        )
    }

    private static func truncatedBinary(_ binary: String, maxLength: Int = 18) -> String {
        guard binary.count > maxLength else { return binary }
        let prefix = binary.prefix(maxLength - 1)
        return "\(prefix)…"
    }
}
