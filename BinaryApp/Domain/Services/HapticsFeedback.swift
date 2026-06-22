import UIKit

protocol HapticsFeedbackProviding: AnyObject {
    func prepare()
    func emit(_ event: HapticEvent)
}

enum HapticEvent {
    case success
    case warning
    case failure
    case selection
    case impact
}

final class HapticsFeedbackProvider: HapticsFeedbackProviding {

    private let notification: UINotificationFeedbackGenerator
    private let selection: UISelectionFeedbackGenerator
    private let impact: UIImpactFeedbackGenerator

    init(
        notification: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator(),
        selection: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator(),
        impact: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    ) {
        self.notification = notification
        self.selection = selection
        self.impact = impact
    }

    func prepare() {
        notification.prepare()
        selection.prepare()
        impact.prepare()
    }

    func emit(_ event: HapticEvent) {
        switch event {
        case .success:
            notification.notificationOccurred(.success)
        case .warning:
            notification.notificationOccurred(.warning)
        case .failure:
            notification.notificationOccurred(.error)
        case .selection:
            selection.selectionChanged()
        case .impact:
            impact.impactOccurred()
        }
    }
}
