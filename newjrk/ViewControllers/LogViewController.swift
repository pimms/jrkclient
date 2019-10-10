import UIKit

class LogViewController: UIViewController {
    var apiClient: ApiClient?
    @IBOutlet private var tableView: UITableView?
    @IBOutlet private var segmentedControl: UISegmentedControl?

    private var logCache: [[LogEntryDTO]?] = []
    private var currentCache: [LogEntryDTO]? {
        set {
            guard let segment = segmentedControl?.selectedSegmentIndex else { return }
            logCache[segment] = newValue
        }
        get {
            guard let segment = segmentedControl?.selectedSegmentIndex else { return nil }
            return logCache[segment]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logCache = Array(repeating: nil, count: segmentedControl?.numberOfSegments ?? 1)
        reloadSelectedSection(useCacheIfExists: true)
    }

    @IBAction private func doneButtonTapped() {
        dismiss(animated: true)
    }

    @IBAction private func segmentedControlChanged() {
        reloadSelectedSection(useCacheIfExists: true)
    }

    private func reloadSelectedSection(useCacheIfExists: Bool) {
        guard let apiClient = apiClient else { return }
        let segment = segmentedControl?.selectedSegmentIndex ?? 0

        if useCacheIfExists, currentCache != nil {
            tableView?.reloadData()
            return
        }

        let fetchFunction = segment == 0
            ? { apiClient.fetchEpisodeLog(completion: $0) }
            : { apiClient.fetchEventLog(completion: $0) }

        fetchFunction { [weak self] result in
            switch result {
            case .success(let entries):
                self?.currentCache = entries
                self?.tableView?.reloadData()
            case .failure(let err):
                print("Failed to fetch logs: \(err)")
            }
        }
    }
}

extension LogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogEntryCell") as? LogEntryCell else {
            fatalError("Failed to dequeue cell with reuse identifier 'LogEntryCell'")
        }

        guard let item = currentCache?[indexPath.row] else {
            fatalError("Index out of bounds")
        }

        cell.configure(withEntry: item)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCache?.count ?? 0
    }
}

extension LogViewController: UITableViewDelegate {

}

// MARK: - LogEntryCell

class LogEntryCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel?
    @IBOutlet private var descriptionLabel: UILabel?

    func configure(withEntry entry: LogEntryDTO) {
        titleLabel?.text = entry.title
        descriptionLabel?.text = entry.description
    }
}
