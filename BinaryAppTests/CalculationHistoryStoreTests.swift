import Testing
import Foundation
@testable import BinaryApp

struct CalculationHistoryStoreTests {

    private func makeStore(suiteName: String = UUID().uuidString) -> (CalculationHistoryStore, UserDefaults) {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = CalculationHistoryStore(defaults: defaults)
        return (store, defaults)
    }

    private func makeCalculation(value: Int, gap: Int = 0) -> BinaryCalculation {
        BinaryCalculation(
            value: value,
            binaryRepresentation: String(value, radix: 2),
            binaryGap: gap
        )
    }

    @Test("Initial load returns an empty array")
    func empty_on_first_load() {
        let (store, _) = makeStore()
        #expect(store.loadAll().isEmpty)
    }

    @Test("Insert prepends the calculation")
    func insert_prepends() {
        let (store, _) = makeStore()
        store.insert(makeCalculation(value: 10))
        store.insert(makeCalculation(value: 20))
        let items = store.loadAll()
        #expect(items.count == 2)
        #expect(items.first?.value == 20)
    }

    @Test("Inserting the same value replaces the older entry")
    func dedupes_by_value() {
        let (store, _) = makeStore()
        store.insert(makeCalculation(value: 10, gap: 1))
        store.insert(makeCalculation(value: 10, gap: 2))
        let items = store.loadAll()
        #expect(items.count == 1)
        #expect(items.first?.binaryGap == 2)
    }

    @Test("Delete removes the matching id")
    func delete_removes_item() {
        let (store, _) = makeStore()
        let first = makeCalculation(value: 100)
        let second = makeCalculation(value: 200)
        store.insert(first)
        store.insert(second)
        store.delete(id: first.id)
        let items = store.loadAll()
        #expect(items.count == 1)
        #expect(items.first?.value == 200)
    }

    @Test("Delete all clears storage")
    func delete_all_clears() {
        let (store, _) = makeStore()
        store.insert(makeCalculation(value: 1))
        store.insert(makeCalculation(value: 2))
        store.deleteAll()
        #expect(store.loadAll().isEmpty)
    }

    @Test("Load recent respects the limit")
    func recent_respects_limit() {
        let (store, _) = makeStore()
        (1...5).forEach { store.insert(makeCalculation(value: $0)) }
        let recents = store.loadRecent(limit: 3)
        #expect(recents.count == 3)
        #expect(recents.map(\.value) == [5, 4, 3])
    }

    @Test("Load recent with zero limit returns an empty array")
    func recent_zero_limit() {
        let (store, _) = makeStore()
        store.insert(makeCalculation(value: 1))
        #expect(store.loadRecent(limit: 0).isEmpty)
    }
}
