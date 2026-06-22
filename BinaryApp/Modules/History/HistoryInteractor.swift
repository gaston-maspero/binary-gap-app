import Foundation

protocol HistoryInteractorInput: AnyObject {
    func fetchAll() -> [BinaryCalculation]
    func delete(id: UUID)
    func deleteAll()
}

final class HistoryInteractor: HistoryInteractorInput {

    private let historyStore: CalculationHistoryStoring

    init(historyStore: CalculationHistoryStoring) {
        self.historyStore = historyStore
    }

    func fetchAll() -> [BinaryCalculation] {
        historyStore.loadAll()
    }

    func delete(id: UUID) {
        historyStore.delete(id: id)
    }

    func deleteAll() {
        historyStore.deleteAll()
    }
}
