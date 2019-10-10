import UIKit

class LogViewController: UIViewController {
    @IBOutlet private var tableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func doneButtonTapped() {
        dismiss(animated: true)
    }
}
