import Foundation

protocol HomeInteractorInput: AnyObject {
    func performCalculation(forValue value: Int) -> BinaryCalculation
    func saveToHistory(_ calculation: BinaryCalculation)
    func fetchRecentCalculations(limit: Int) -> [BinaryCalculation]
    func fetchCalculation(id: UUID) -> BinaryCalculation?
}

final class HomeInteractor: HomeInteractorInput {

    // MARK: - Dependencies

    private let calculator: BinaryGapCalculating
    private let historyStore: CalculationHistoryStoring

    // MARK: - Init

    init(
        calculator: BinaryGapCalculating,
        historyStore: CalculationHistoryStoring
    ) {
        self.calculator = calculator
        self.historyStore = historyStore
    }

    // MARK: - HomeInteractorInput

    func performCalculation(forValue value: Int) -> BinaryCalculation {
        calculator.calculate(for: value)
    }

    func saveToHistory(_ calculation: BinaryCalculation) {
        historyStore.insert(calculation)
    }

    func fetchRecentCalculations(limit: Int) -> [BinaryCalculation] {
        historyStore.loadRecent(limit: limit)
    }

    func fetchCalculation(id: UUID) -> BinaryCalculation? {
        historyStore.loadAll().first { $0.id == id }
    }
}
