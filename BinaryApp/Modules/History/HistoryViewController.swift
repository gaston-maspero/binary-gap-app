import UIKit

protocol HistoryViewInput: AnyObject {
    func render(_ viewModel: HistoryViewModel)
    func display(rows: [HistoryRowViewModel])
    func showEmptyState(_ message: String)
    func showClearAllButton(_ isVisible: Bool)
}

final class HistoryViewController: UIViewController {

    // MARK: - VIPER

    private let presenter: HistoryViewOutput

    // MARK: - Data source

    private typealias DataSource = UITableViewDiffableDataSource<Int, HistoryRowViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, HistoryRowViewModel>
    private var dataSource: DataSource!
    private let mainSection = 0

    // MARK: - Subviews

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = Theme.Color.background
        table.estimatedRowHeight = 96
        table.rowHeight = UITableView.automaticDimension
        return table
    }()

    private let emptyStateView: HistoryEmptyStateView = {
        let view = HistoryEmptyStateView()
        view.isHidden = true
        return view
    }()

    private lazy var clearAllButton: UIBarButtonItem = UIBarButtonItem(
        title: "Clear all",
        style: .plain,
        target: self,
        action: #selector(didTapClearAll)
    )

    // MARK: - Init

    init(presenter: HistoryViewOutput) {
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
        configureTable()
        configureLayout()
        clearAllButton.tintColor = Theme.Color.error
        presenter.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    // MARK: - Setup

    private func configureTable() {
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseIdentifier)
        tableView.delegate = self

        dataSource = DataSource(tableView: tableView) { tableView, indexPath, model in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: HistoryCell.reuseIdentifier,
                for: indexPath
            ) as? HistoryCell ?? HistoryCell(style: .default, reuseIdentifier: HistoryCell.reuseIdentifier)
            cell.configure(with: model)
            return cell
        }
        dataSource.defaultRowAnimation = .fade
    }

    private func configureLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Theme.Spacing.large),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Theme.Spacing.large)
        ])
    }

    @objc private func didTapClearAll() {
        presenter.didTapClearAll()
    }
}

// MARK: - UITableViewDelegate

extension HistoryViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.presenter.didTapDelete(rowID: item.id)
            completion(true)
        }
        action.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - HistoryViewInput

extension HistoryViewController: HistoryViewInput {

    func render(_ viewModel: HistoryViewModel) {
        title = viewModel.title
        clearAllButton.title = viewModel.clearAllTitle
        emptyStateView.update(message: viewModel.emptyMessage)
    }

    func display(rows: [HistoryRowViewModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([mainSection])
        snapshot.appendItems(rows, toSection: mainSection)
        dataSource.apply(snapshot, animatingDifferences: true)
        let isEmpty = rows.isEmpty
        UIView.animate(withDuration: Theme.Animation.quick) {
            self.emptyStateView.isHidden = !isEmpty
            self.tableView.isHidden = isEmpty
        }
    }

    func showEmptyState(_ message: String) {
        emptyStateView.update(message: message)
    }

    func showClearAllButton(_ isVisible: Bool) {
        navigationItem.rightBarButtonItem = isVisible ? clearAllButton : nil
    }
}
