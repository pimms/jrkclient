import Foundation
import UIKit
import AVKit
import jrkKitTV

class PlayerViewController: UIViewController {

    // MARK: - Private properties

    private lazy var log = Log(for: self)
    private let streamPlayer: StreamPlayer

    // MARK: - UI properties

    private lazy var avPlayerViewController: AVPlayerViewController = {
        let vc = AVPlayerViewController()
        vc.player = streamPlayer.player
        vc.delegate = self
        return vc
    }()

    // MARK: - Init

    required init?(coder: NSCoder) {
        fatalError()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }

    required init(streamPlayer: StreamPlayer) {
        self.streamPlayer = streamPlayer
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        streamPlayer.play()
    }

    private func setup() {
        add(avPlayerViewController)

        let overlay = makeContentOverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        avPlayerViewController.contentOverlayView?.addSubview(overlay)
        overlay.fillInSuperview(padding: 128)
    }

    private func makeContentOverlayView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 64

        if let image = streamPlayer.streamPicture {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)
        }

        if let logo = UIImage(named: "jrkLight") {
            let imageView = UIImageView(image: logo)
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)
        }

        return stackView
    }
}

extension PlayerViewController: AVPlayerViewControllerDelegate {

}
