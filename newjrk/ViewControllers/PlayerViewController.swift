import UIKit

fileprivate enum PlayerError: String, Error {
    case notConfigured
    case alreadyConfigured
}

class PlayerViewController: UIViewController {

    // MARK: - Private properties

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var currentlyPlayingLabel: UILabel?
    @IBOutlet private var playButton: UIButton?

    private lazy var log = Log(for: self)
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
        streamPlayer.addDelegate(self)
        isConfigured = true
    }

    // MARK: - IBActions

    @IBAction private func playButtonTapped() {
        switch streamPlayer.state {
        case .playing:
            log.log("Pausing")
            streamPlayer.pause()
        case .paused, .notPlaying, .failed:
            log.log("Playing")
            streamPlayer.play()
        default:
            log.log("Nothing to do for PlayerState '\(streamPlayer.state)'")
        }
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

// MARK: - StreamPlayerDelegate

extension PlayerViewController: StreamPlayerDelegate {
    func streamPlayerChangedState(_ streamPlayer: StreamPlayer) {
        let image = playerButtonImage(for: streamPlayer.state)
        playButton?.setBackgroundImage(image, for: .normal)
    }

    private func playerButtonImage(for state: PlayerState) -> UIImage? {
        switch state {
        case .playing:
            return UIImage(systemName: "stop.circle")
        case .paused, .notPlaying:
            return UIImage(systemName: "play.circle")
        case .buffering:
            return UIImage(systemName: "arrow.clockwise.circle")
        case .failed:
            return UIImage(systemName: "exclamationmark.circle")
        }
    }
}
