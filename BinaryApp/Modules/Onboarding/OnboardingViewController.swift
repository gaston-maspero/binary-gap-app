import UIKit

protocol OnboardingViewInput: AnyObject {
    func render(pages: [OnboardingPageViewModel])
    func setVisiblePage(_ index: Int, totalPages: Int, animated: Bool)
    func setPrimaryActionTitle(_ title: String)
    func close()
}

final class OnboardingViewController: UIViewController {

    // MARK: - VIPER

    private let presenter: OnboardingViewOutput

    // MARK: - Subviews

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInsetAdjustmentBehavior = .never
        return scroll
    }()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = Theme.Color.primary
        control.pageIndicatorTintColor = Theme.Color.separator
        control.isUserInteractionEnabled = false
        return control
    }()

    private let primaryButton = GradientButton()

    private let skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Skip"
        let button = UIButton(configuration: config)
        button.tintColor = Theme.Color.textSecondary
        return button
    }()

    // MARK: - State

    private var pageViews: [OnboardingPageView] = []

    // MARK: - Init

    init(presenter: OnboardingViewOutput) {
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
        buildLayout()
        attachActions()
        presenter.viewIsReady()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.width * CGFloat(pageViews.count),
            height: scrollView.bounds.height
        )
    }

    // MARK: - Setup

    private func buildLayout() {
        view.addSubview(skipButton)
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(primaryButton)
        scrollView.addSubview(stack)

        skipButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Theme.Spacing.small),
            skipButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Theme.Spacing.medium),

            scrollView.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: Theme.Spacing.small),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -Theme.Spacing.medium),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -Theme.Spacing.medium),

            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Spacing.large),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Spacing.large),
            primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Theme.Spacing.large)
        ])

        scrollView.delegate = self
    }

    private func attachActions() {
        primaryButton.addTarget(self, action: #selector(didTapPrimary), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapPrimary() {
        presenter.didTapPrimaryAction()
    }

    @objc private func didTapSkip() {
        presenter.didTapSkip()
    }
}

// MARK: - UIScrollViewDelegate

extension OnboardingViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        let pageIndex = Int(round(scrollView.contentOffset.x / pageWidth))
        presenter.didChangeVisiblePage(index: pageIndex)
    }
}

// MARK: - OnboardingViewInput

extension OnboardingViewController: OnboardingViewInput {

    func render(pages: [OnboardingPageViewModel]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pageViews.removeAll()

        for model in pages {
            let pageView = OnboardingPageView()
            pageView.configure(with: model)
            stack.addArrangedSubview(pageView)
            pageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
            pageViews.append(pageView)
        }
        pageControl.numberOfPages = pages.count
        view.layoutIfNeeded()
    }

    func setVisiblePage(_ index: Int, totalPages: Int, animated: Bool) {
        pageControl.numberOfPages = totalPages
        pageControl.currentPage = index
        let offset = CGPoint(x: scrollView.bounds.width * CGFloat(index), y: 0)
        scrollView.setContentOffset(offset, animated: animated)
    }

    func setPrimaryActionTitle(_ title: String) {
        primaryButton.title = title
    }

    func close() {
        dismiss(animated: true)
    }
}
