import UIKit

protocol HistoryRouting: AnyObject {
    func presentClearAllConfirmation(onConfirm: @escaping () -> Void)
}

final class HistoryRouter: HistoryRouting {

    weak var sourceViewController: UIViewController?

    func presentClearAllConfirmation(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Clear all history?",
            message: "This will permanently remove every saved calculation.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Clear all", style: .destructive) { _ in
            onConfirm()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sourceViewController?.present(alert, animated: true)
    }
}
