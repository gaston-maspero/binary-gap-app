import Foundation

// MARK: - View output

protocol HistoryViewOutput: AnyObject {
    func viewIsReady()
    func viewWillAppear()
    func didTapClearAll()
    func didConfirmClearAll()
    func didTapDelete(rowID: UUID)
}

// MARK: - View models

struct HistoryViewModel: Equatable {
    let title: String
    let emptyMessage: String
    let clearAllTitle: String
}

nonisolated struct HistoryRowViewModel: Hashable, Sendable {
    let id: UUID
    let valueText: String
    let binaryText: String
    let gapText: String
    let dateText: String
    let accessibilityLabel: String
}

// MARK: - Presenter

final class HistoryPresenter {

    weak var view: HistoryViewInput?

    private let interactor: HistoryInteractorInput
    private let router: HistoryRouting
    private let haptics: HapticsFeedbackProviding

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    init(
        interactor: HistoryInteractorInput,
        router: HistoryRouting,
        haptics: HapticsFeedbackProviding
    ) {
        self.interactor = interactor
        self.router = router
        self.haptics = haptics
    }

    private func reloadRows() {
        let calculations = interactor.fetchAll()
        if calculations.isEmpty {
            view?.showEmptyState("No calculations yet. Compute one from the home screen to see it here.")
            view?.showClearAllButton(false)
            view?.display(rows: [])
            return
        }
        view?.showClearAllButton(true)
        view?.display(rows: calculations.map(makeRow))
    }

    private func makeRow(from calculation: BinaryCalculation) -> HistoryRowViewModel {
        HistoryRowViewModel(
            id: calculation.id,
            valueText: "\(calculation.value.formatted())",
            binaryText: calculation.binaryRepresentation,
            gapText: "Gap \(calculation.binaryGap)",
            dateText: dateFormatter.string(from: calculation.createdAt),
            accessibilityLabel: "Decimal \(calculation.value), binary \(calculation.binaryRepresentation), longest gap \(calculation.binaryGap), saved \(dateFormatter.string(from: calculation.createdAt))."
        )
    }
}

// MARK: - HistoryViewOutput

extension HistoryPresenter: HistoryViewOutput {

    func viewIsReady() {
        view?.render(
            HistoryViewModel(
                title: "History",
                emptyMessage: "No calculations yet.",
                clearAllTitle: "Clear all"
            )
        )
        haptics.prepare()
    }

    func viewWillAppear() {
        reloadRows()
    }

    func didTapClearAll() {
        haptics.emit(.selection)
        router.presentClearAllConfirmation { [weak self] in
            self?.didConfirmClearAll()
        }
    }

    func didConfirmClearAll() {
        interactor.deleteAll()
        haptics.emit(.warning)
        reloadRows()
    }

    func didTapDelete(rowID: UUID) {
        interactor.delete(id: rowID)
        haptics.emit(.impact)
        reloadRows()
    }
}
