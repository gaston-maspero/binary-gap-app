import UIKit

final class RecentItemControl: UIControl {

    // MARK: - Public

    private(set) var itemID: UUID?

    // MARK: - Subviews

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.headline
        label.textColor = Theme.Color.textPrimary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let binaryLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.monoSmall
        label.textColor = Theme.Color.textSecondary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let gapLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.footnote
        label.textColor = Theme.Color.textTertiary
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()

    private let chevron: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = Theme.Color.textTertiary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    // MARK: - Public API

    func configure(with model: HomeRecentItemViewModel) {
        itemID = model.id
        valueLabel.text = model.title
        binaryLabel.text = model.binarySnippet
        gapLabel.text = model.gapDescription
        accessibilityLabel = model.accessibilityLabel
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    // MARK: - Touch handling

    override var isHighlighted: Bool {
        didSet { applyHighlight() }
    }

    // MARK: - Layout

    private func configure() {
        backgroundColor = Theme.Color.surfaceElevated
        layer.cornerRadius = Theme.Radius.medium
        layer.cornerCurve = .continuous

        let textStack = UIStackView(arrangedSubviews: [valueLabel, binaryLabel, gapLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.isUserInteractionEnabled = false

        let container = UIStackView(arrangedSubviews: [textStack, chevron])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = Theme.Spacing.medium
        container.isUserInteractionEnabled = false

        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Spacing.medium),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Spacing.medium),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Spacing.medium),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Spacing.medium),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    private func applyHighlight() {
        UIView.animate(withDuration: Theme.Animation.quick) {
            self.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.98, y: 0.98)
                : .identity
            self.alpha = self.isHighlighted ? 0.85 : 1.0
        }
    }
}
