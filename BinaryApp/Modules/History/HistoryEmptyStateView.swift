import UIKit

final class HistoryEmptyStateView: UIView {

    private let iconView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
        let view = UIImageView(image: UIImage(systemName: "tray", withConfiguration: configuration))
        view.tintColor = Theme.Color.textTertiary
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.body
        label.textColor = Theme.Color.textSecondary
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    func update(message: String) {
        messageLabel.text = message
    }

    private func configure() {
        let stack = UIStackView(arrangedSubviews: [iconView, messageLabel])
        stack.axis = .vertical
        stack.spacing = Theme.Spacing.medium
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
