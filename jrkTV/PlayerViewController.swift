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
    }

    private func setup() {
        add(avPlayerViewController)
    }
}

extension PlayerViewController: AVPlayerViewControllerDelegate {

}
