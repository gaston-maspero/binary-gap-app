import UIKit

final class CardView: UIView {

    var contentInsets: UIEdgeInsets = UIEdgeInsets(
        top: Theme.Spacing.large,
        left: Theme.Spacing.large,
        bottom: Theme.Spacing.large,
        right: Theme.Spacing.large
    ) {
        didSet { applyContentInsets() }
    }

    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Theme.Spacing.medium
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private var contentConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyShadow()
        }
    }

    private func setupAppearance() {
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Radius.large
        layer.cornerCurve = .continuous
        applyShadow()

        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        applyContentInsets()
    }

    private func applyContentInsets() {
        NSLayoutConstraint.deactivate(contentConstraints)
        contentConstraints = [
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)
        ]
        NSLayoutConstraint.activate(contentConstraints)
    }

    private func applyShadow() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = isDark ? 0.4 : 0.08
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = isDark ? 18 : 12
    }
}
