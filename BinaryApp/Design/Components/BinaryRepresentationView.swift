import UIKit

/// Displays the binary representation of a number as a row of bit chips,
/// highlighting the longest gap of zeros surrounded by ones.
final class BinaryRepresentationView: UIView {

    struct Configuration: Equatable {
        let binary: String
        let gapRange: Range<Int>?
    }

    // MARK: - Subviews

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true
        return scroll
    }()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    // MARK: - Public

    func render(_ configuration: Configuration, animated: Bool) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, character) in configuration.binary.enumerated() {
            let chip = makeBitChip(
                bit: character,
                isInsideGap: configuration.gapRange?.contains(index) ?? false
            )
            stack.addArrangedSubview(chip)
        }

        guard animated else { return }

        for (index, chip) in stack.arrangedSubviews.enumerated() {
            chip.alpha = 0
            chip.transform = CGAffineTransform(translationX: 0, y: 6)
            UIView.animate(
                withDuration: Theme.Animation.standard,
                delay: TimeInterval(index) * 0.025,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.4,
                options: [.allowUserInteraction]
            ) {
                chip.alpha = 1
                chip.transform = .identity
            }
        }
    }

    // MARK: - Setup

    private func setupLayout() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    private func makeBitChip(bit: Character, isInsideGap: Bool) -> UIView {
        let label = UILabel()
        label.text = String(bit)
        label.font = Theme.Font.monoMedium
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true

        let container = UIView()
        container.layer.cornerRadius = Theme.Radius.small
        container.layer.cornerCurve = .continuous

        if bit == "1" {
            container.backgroundColor = Theme.Color.bitOne.withAlphaComponent(0.18)
            label.textColor = Theme.Color.bitOne
        } else if isInsideGap {
            container.backgroundColor = Theme.Color.bitZeroInsideGap.withAlphaComponent(0.20)
            label.textColor = Theme.Color.bitZeroInsideGap
            container.layer.borderColor = Theme.Color.bitZeroInsideGap.withAlphaComponent(0.5).cgColor
            container.layer.borderWidth = 1
        } else {
            container.backgroundColor = UIColor.tertiarySystemFill
            label.textColor = Theme.Color.bitZero
        }

        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 32)
        ])

        container.isAccessibilityElement = true
        container.accessibilityLabel = bit == "1"
            ? "Bit one"
            : (isInsideGap ? "Bit zero inside gap" : "Bit zero")
        return container
    }
}
