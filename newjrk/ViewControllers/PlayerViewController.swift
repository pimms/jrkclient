import UIKit

fileprivate enum PlayerError: String, Error {
    case notConfigured
    case alreadyConfigured
}

class PlayerViewController: UIViewController {

    // MARK: - Private properties

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var currentlyPlayingLabel: UILabel?
    @IBOutlet private var playbutton: UIButton?

    private var isConfigured = false
    private var streamPlayer: StreamPlayer!

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

    func setup(streamPlayer: StreamPlayer) {
        self.streamPlayer = streamPlayer
        isConfigured = true
    }

    // MARK: - IBActions

    @IBAction private func playButtonTapped() {

    }
}

// MARK: - Setup

extension PlayerViewController {
    private func setupStreamPicture() {
        let serverConfig = streamPlayer.serverConfiguration
        if let path = serverConfig.picturePath, let data = try? Data(contentsOf: path), let image = UIImage(data: data) {
            imageView?.image = image
        }
    }
}
