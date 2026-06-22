import UIKit

final class HistoryCell: UITableViewCell {

    static let reuseIdentifier = "HistoryCell"

    // MARK: - Subviews

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Color.surface
        view.layer.cornerRadius = Theme.Radius.medium
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.title2
        label.textColor = Theme.Color.textPrimary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let gapBadge: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.footnote.withTraits(traits: .traitBold)
        label.textColor = Theme.Color.textOnPrimary
        label.backgroundColor = Theme.Color.primary
        label.layer.cornerRadius = Theme.Radius.small
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let binaryLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.monoSmall
        label.textColor = Theme.Color.textSecondary
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.footnote
        label.textColor = Theme.Color.textTertiary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - Public API

    func configure(with model: HistoryRowViewModel) {
        valueLabel.text = model.valueText
        binaryLabel.text = model.binaryText
        gapBadge.text = "  \(model.gapText)  "
        dateLabel.text = model.dateText
        accessibilityLabel = model.accessibilityLabel
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    // MARK: - Setup

    private func setupLayout() {
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false

        let header = UIStackView(arrangedSubviews: [valueLabel, UIView(), gapBadge])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = Theme.Spacing.small

        let stack = UIStackView(arrangedSubviews: [header, binaryLabel, dateLabel])
        stack.axis = .vertical
        stack.spacing = Theme.Spacing.xSmall

        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.xSmall),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.xSmall),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.medium),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.medium),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Theme.Spacing.medium),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Theme.Spacing.medium),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Theme.Spacing.medium),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Theme.Spacing.medium),

            gapBadge.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}

private extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
