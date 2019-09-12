import UIKit

fileprivate enum PlayerError: String, Error {
    case notConfigured
    case alreadyConfigured
}

class PlayerViewController: UIViewController {

    // MARK: - Private properties

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var currentlyPlayingLabel: UILabel?

    private var isConfigured = false
    private var serverConfiguration: ServerConfiguration!

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        guard isConfigured else {
            fatalError("PlayerViewController is not configured")
        }

        setupStreamPicture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Internal methods

    func setup(withServerConfiguration config: ServerConfiguration) {
        serverConfiguration = config
        isConfigured = true
    }
}

// MARK: - Setup

extension PlayerViewController {
    private func setupStreamPicture() {
        if let path = serverConfiguration.picturePath, let data = try? Data(contentsOf: path), let image = UIImage(data: data) {
            imageView?.image = image
        }
    }
}
