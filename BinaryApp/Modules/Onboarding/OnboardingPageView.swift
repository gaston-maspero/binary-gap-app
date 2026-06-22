import UIKit

final class OnboardingPageView: UIView {

    // MARK: - Subviews

    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = Theme.Color.primary
        return view
    }()

    private let iconBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Color.primary.withAlphaComponent(0.15)
        view.layer.cornerRadius = 56
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.title
        label.textColor = Theme.Color.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.body
        label.textColor = Theme.Color.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
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

    func configure(with model: OnboardingPageViewModel) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
        iconView.image = UIImage(systemName: model.iconSystemName, withConfiguration: configuration)
        titleLabel.text = model.title
        bodyLabel.text = model.body
        accessibilityLabel = model.accessibilityLabel
        isAccessibilityElement = true
    }

    // MARK: - Setup

    private func configure() {
        addSubview(iconBackground)
        iconBackground.addSubview(iconView)
        addSubview(titleLabel)
        addSubview(bodyLabel)

        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconBackground.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Spacing.xLarge),
            iconBackground.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 112),
            iconBackground.heightAnchor.constraint(equalToConstant: 112),

            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.topAnchor.constraint(equalTo: iconBackground.bottomAnchor, constant: Theme.Spacing.xLarge),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Spacing.large),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Spacing.large),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.Spacing.medium),
            bodyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Spacing.large),
            bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Spacing.large),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Theme.Spacing.large)
        ])
    }
}
