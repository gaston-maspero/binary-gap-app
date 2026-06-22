import Foundation

protocol CalculationHistoryStoring: AnyObject {
    func loadAll() -> [BinaryCalculation]
    func loadRecent(limit: Int) -> [BinaryCalculation]
    func insert(_ calculation: BinaryCalculation)
    func delete(id: UUID)
    func deleteAll()
}

final class CalculationHistoryStore: CalculationHistoryStoring {

    // MARK: - Configuration

    private enum Constants {
        static let storageKey = "com.binaryapp.calculation_history"
        static let maximumStoredItems = 100
    }

    // MARK: - Dependencies

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let queue = DispatchQueue(label: "com.binaryapp.history.store", attributes: .concurrent)

    init(
        defaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    // MARK: - CalculationHistoryStoring

    func loadAll() -> [BinaryCalculation] {
        queue.sync { readFromStorage() }
    }

    func loadRecent(limit: Int) -> [BinaryCalculation] {
        guard limit > 0 else { return [] }
        return Array(loadAll().prefix(limit))
    }

    func insert(_ calculation: BinaryCalculation) {
        queue.sync(flags: .barrier) {
            var items = readFromStorage()
            items.removeAll { $0.value == calculation.value }
            items.insert(calculation, at: 0)
            if items.count > Constants.maximumStoredItems {
                items = Array(items.prefix(Constants.maximumStoredItems))
            }
            writeToStorage(items)
        }
    }

    func delete(id: UUID) {
        queue.sync(flags: .barrier) {
            var items = readFromStorage()
            items.removeAll { $0.id == id }
            writeToStorage(items)
        }
    }

    func deleteAll() {
        queue.sync(flags: .barrier) {
            defaults.removeObject(forKey: Constants.storageKey)
        }
    }

    // MARK: - Storage helpers

    private func readFromStorage() -> [BinaryCalculation] {
        guard let data = defaults.data(forKey: Constants.storageKey) else { return [] }
        return (try? decoder.decode([BinaryCalculation].self, from: data)) ?? []
    }

    private func writeToStorage(_ items: [BinaryCalculation]) {
        guard let data = try? encoder.encode(items) else { return }
        defaults.set(data, forKey: Constants.storageKey)
    }
}
