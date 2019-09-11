import UIKit

fileprivate enum PlayerError: String, Error {
    case notConfigured
    case alreadyConfigured
}

class PlayerViewController: UIViewController {

    // MARK: - Private properties

    private var isConfigured = false
    private var serverConfiguration: ServerConfiguration!

    // MARK: - Overrides

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isConfigured else {
            UIAlertController.display(error: PlayerError.notConfigured, in: self)
            return
        }
    }

    // MARK: - Internal methods

    func setup(withServerConfiguration config: ServerConfiguration) {
        guard !isConfigured else {
            UIAlertController.display(error: PlayerError.alreadyConfigured, in: self)
            return
        }

        serverConfiguration = config
        isConfigured = true
    }
}
