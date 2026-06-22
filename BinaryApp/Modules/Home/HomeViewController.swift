import UIKit

protocol HomeViewInput: AnyObject {
    func render(_ viewModel: HomeViewModel)
    func display(result: HomeResultViewModel, animated: Bool)
    func clearResult()
    func displayValidationMessage(_ message: String?)
    func display(recentCalculations: [HomeRecentItemViewModel])
    func setCalculateEnabled(_ isEnabled: Bool)
}

final class HomeViewController: UIViewController {

    // MARK: - VIPER

    private let presenter: HomeViewOutput

    // MARK: - Subviews

    private let scrollView = UIScrollView()
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Theme.Spacing.large
        return stack
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Theme.Spacing.small
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.largeTitle
        label.textColor = Theme.Color.textPrimary
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.body
        label.textColor = Theme.Color.textSecondary
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let inputCard = CardView()

    private let inputFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Positive integer"
        label.font = Theme.Font.footnote
        label.textColor = Theme.Color.textSecondary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let inputField: UITextField = {
        let field = UITextField()
        field.font = Theme.Font.monoLarge
        field.keyboardType = .numberPad
        field.textColor = Theme.Color.textPrimary
        field.adjustsFontForContentSizeCategory = true
        field.clearButtonMode = .whileEditing
        field.borderStyle = .none
        return field
    }()

    private let inputDivider: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Color.separator
        return view
    }()

    private let validationLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.footnote
        label.textColor = Theme.Color.error
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.isHidden = true
        return label
    }()

    private let calculateButton = GradientButton()

    private let resultCard = CardView()

    private let resultValueLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.footnote
        label.textColor = Theme.Color.textSecondary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let binaryView = BinaryRepresentationView()

    private let gapNumberLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.monoLarge.withSize(56)
        label.textColor = Theme.Color.primary
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    private let gapCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.callout
        label.textColor = Theme.Color.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let recentSectionCard = CardView()

    private let recentHeader: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        return stack
    }()

    private let recentTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.headline
        label.textColor = Theme.Color.textPrimary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let viewAllButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.setTitleColor(Theme.Color.primary, for: .normal)
        return button
    }()

    private let recentListStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Theme.Spacing.small
        return stack
    }()

    private let emptyRecentLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.footnote
        label.textColor = Theme.Color.textTertiary
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Init

    init(presenter: HomeViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background
        configureNavigationBar()
        buildHierarchy()
        installConstraints()
        attachActions()
        resultCard.isHidden = true
        registerKeyboardHandling()
        presenter.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    // MARK: - Setup

    private func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func buildHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(subtitleLabel)

        let inputFieldStack = UIStackView(arrangedSubviews: [
            inputFieldLabel, inputField, inputDivider, validationLabel
        ])
        inputFieldStack.axis = .vertical
        inputFieldStack.spacing = Theme.Spacing.small
        inputFieldStack.setCustomSpacing(Theme.Spacing.xSmall, after: inputField)
        inputFieldStack.setCustomSpacing(Theme.Spacing.small, after: inputDivider)

        inputCard.contentStack.addArrangedSubview(inputFieldStack)
        inputCard.contentStack.addArrangedSubview(calculateButton)
        inputCard.contentStack.setCustomSpacing(Theme.Spacing.large, after: inputFieldStack)

        resultCard.contentStack.spacing = Theme.Spacing.medium
        resultCard.contentStack.addArrangedSubview(resultValueLabel)
        resultCard.contentStack.addArrangedSubview(binaryView)
        resultCard.contentStack.addArrangedSubview(gapNumberLabel)
        resultCard.contentStack.addArrangedSubview(gapCaptionLabel)
        resultCard.contentStack.setCustomSpacing(Theme.Spacing.small, after: gapNumberLabel)

        recentHeader.addArrangedSubview(recentTitleLabel)
        recentHeader.addArrangedSubview(UIView())
        recentHeader.addArrangedSubview(viewAllButton)

        recentSectionCard.contentInsets = UIEdgeInsets(
            top: Theme.Spacing.medium,
            left: Theme.Spacing.medium,
            bottom: Theme.Spacing.medium,
            right: Theme.Spacing.medium
        )
        recentSectionCard.contentStack.spacing = Theme.Spacing.medium
        recentSectionCard.contentStack.addArrangedSubview(recentHeader)
        recentSectionCard.contentStack.addArrangedSubview(recentListStack)
        recentSectionCard.contentStack.addArrangedSubview(emptyRecentLabel)

        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(inputCard)
        contentStack.addArrangedSubview(resultCard)
        contentStack.addArrangedSubview(recentSectionCard)
    }

    private func installConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        binaryView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: Theme.Spacing.large
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -Theme.Spacing.xxLarge
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: Theme.Spacing.large
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -Theme.Spacing.large
            ),
            contentStack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -Theme.Spacing.large * 2
            ),

            inputDivider.heightAnchor.constraint(equalToConstant: 1),
            binaryView.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func attachActions() {
        inputField.addTarget(self, action: #selector(inputDidChange), for: .editingChanged)
        inputField.delegate = self
        inputField.inputAccessoryView = makeKeyboardAccessoryToolbar()

        calculateButton.addTarget(self, action: #selector(didTapCalculate), for: .touchUpInside)
        viewAllButton.addTarget(self, action: #selector(didTapViewAll), for: .touchUpInside)
    }

    private func registerKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func makeKeyboardAccessoryToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )
        toolbar.items = [spacer, done]
        toolbar.sizeToFit()
        return toolbar
    }

    // MARK: - Actions

    @objc private func inputDidChange() {
        presenter.didChangeInput(inputField.text)
    }

    @objc private func didTapCalculate() {
        view.endEditing(true)
        presenter.didTapCalculate()
    }

    @objc private func didTapViewAll() {
        presenter.didTapShowFullHistory()
    }

    @objc private func didTapHelp() {
        presenter.didTapShowHelp()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func didTapRecentItem(_ sender: UIControl) {
        guard let id = (sender as? RecentItemControl)?.itemID else { return }
        presenter.didSelectRecent(itemID: id)
    }
}

// MARK: - UITextFieldDelegate

extension HomeViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard !string.isEmpty else { return true }
        return CharacterSet(charactersIn: string).isSubset(of: .decimalDigits)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - HomeViewInput

extension HomeViewController: HomeViewInput {

    func render(_ viewModel: HomeViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        inputField.placeholder = viewModel.inputPlaceholder
        inputField.accessibilityHint = viewModel.inputAccessibilityHint
        calculateButton.title = viewModel.calculateTitle
        calculateButton.setIcon(systemName: "function")
        recentTitleLabel.text = viewModel.recentTitle
        viewAllButton.setTitle(viewModel.viewAllTitle, for: .normal)
        emptyRecentLabel.text = viewModel.emptyRecentMessage

        let helpButton = UIBarButtonItem(
            image: UIImage(systemName: "questionmark.circle"),
            style: .plain,
            target: self,
            action: #selector(didTapHelp)
        )
        helpButton.accessibilityLabel = "Help"
        navigationItem.rightBarButtonItem = helpButton
        navigationController?.setNavigationBarHidden(false, animated: false)
        title = viewModel.title
    }

    func display(result: HomeResultViewModel, animated: Bool) {
        resultValueLabel.text = result.valueText
        binaryView.render(result.binaryRepresentation, animated: animated)
        gapNumberLabel.text = result.gapText
        gapCaptionLabel.text = result.summary
        resultCard.accessibilityLabel = result.accessibilitySummary
        resultCard.isAccessibilityElement = true

        guard animated else {
            resultCard.isHidden = false
            return
        }

        if resultCard.isHidden {
            resultCard.alpha = 0
            resultCard.transform = CGAffineTransform(translationX: 0, y: 12)
            resultCard.isHidden = false
            UIView.animate(
                withDuration: Theme.Animation.emphasized,
                delay: 0,
                usingSpringWithDamping: 0.78,
                initialSpringVelocity: 0.4
            ) {
                self.resultCard.alpha = 1
                self.resultCard.transform = .identity
            }
        } else {
            UIView.transition(
                with: resultCard,
                duration: Theme.Animation.standard,
                options: .transitionCrossDissolve,
                animations: nil
            )
        }

        UIAccessibility.post(notification: .announcement, argument: result.accessibilitySummary)
    }

    func clearResult() {
        UIView.animate(withDuration: Theme.Animation.quick) {
            self.resultCard.alpha = 0
        } completion: { _ in
            self.resultCard.isHidden = true
            self.resultCard.alpha = 1
        }
    }

    func displayValidationMessage(_ message: String?) {
        validationLabel.text = message
        UIView.animate(withDuration: Theme.Animation.quick) {
            self.validationLabel.isHidden = (message == nil)
            self.inputDivider.backgroundColor = (message != nil)
                ? Theme.Color.error.withAlphaComponent(0.7)
                : Theme.Color.separator
        }
    }

    func display(recentCalculations: [HomeRecentItemViewModel]) {
        recentListStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if recentCalculations.isEmpty {
            emptyRecentLabel.isHidden = false
            viewAllButton.isHidden = true
            recentListStack.isHidden = true
            return
        }

        emptyRecentLabel.isHidden = true
        viewAllButton.isHidden = false
        recentListStack.isHidden = false

        for item in recentCalculations {
            let control = RecentItemControl()
            control.configure(with: item)
            control.addTarget(self, action: #selector(didTapRecentItem(_:)), for: .touchUpInside)
            recentListStack.addArrangedSubview(control)
        }
    }

    func setCalculateEnabled(_ isEnabled: Bool) {
        calculateButton.isEnabled = isEnabled
    }
}
