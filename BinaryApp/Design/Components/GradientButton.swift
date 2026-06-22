import UIKit

final class GradientButton: UIControl {

    // MARK: - Public API

    var title: String? {
        didSet { titleLabel.text = title }
    }

    var icon: UIImage? {
        didSet { iconView.image = icon }
    }

    override var isEnabled: Bool {
        didSet { applyEnabledAppearance() }
    }

    // MARK: - Subviews

    private let gradientLayer = CAGradientLayer()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.headline
        label.textColor = Theme.Color.textOnPrimary
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = Theme.Color.textOnPrimary
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Theme.Spacing.small
        stack.isUserInteractionEnabled = false
        return stack
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = Theme.Radius.medium
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 54)
    }

    // MARK: - Touch handling

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        animatePress(scale: 0.97)
        return super.beginTracking(touch, with: event)
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        animatePress(scale: 1.0)
        super.endTracking(touch, with: event)
    }

    override func cancelTracking(with event: UIEvent?) {
        animatePress(scale: 1.0)
        super.cancelTracking(with: event)
    }

    // MARK: - Setup

    private func setupAppearance() {
        layer.cornerRadius = Theme.Radius.medium
        layer.masksToBounds = false
        layer.shadowColor = Theme.Color.primary.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12

        gradientLayer.colors = [
            Theme.Color.primary.cgColor,
            Theme.Color.primaryGradientEnd.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = Theme.Radius.medium
        layer.insertSublayer(gradientLayer, at: 0)

        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])

        iconView.isHidden = true
    }

    private func applyEnabledAppearance() {
        UIView.animate(withDuration: Theme.Animation.quick) {
            self.alpha = self.isEnabled ? 1.0 : 0.5
        }
    }

    private func animatePress(scale: CGFloat) {
        UIView.animate(
            withDuration: Theme.Animation.quick,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

extension GradientButton {

    func setIcon(systemName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        icon = UIImage(systemName: systemName, withConfiguration: config)
        iconView.isHidden = icon == nil
    }
}
