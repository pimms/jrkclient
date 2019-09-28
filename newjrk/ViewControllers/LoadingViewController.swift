import UIKit

class LoadingViewController: UIViewController {
    private enum LoadingError: String, Error {
        case rootUrlMissing = "No root-URL is defined for the preferred server configuration."
    }

    @IBOutlet private var activityIndicator: UIActivityIndicatorView?

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator?.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.shared.addStreamSetupDelegate(self)
    }

    // MARK: - Private methods

    private func presentInitialConfiguration() {
        let vc = UIStoryboard.instantiate(InitialConfigViewController.self)
        present(vc)
    }

    private func presentPlayerViewController(streamPlayer: StreamPlayer) {
        let vc = UIStoryboard.instantiate(PlayerViewController.self)
        vc.setup(streamPlayer: streamPlayer)
        present(vc)
    }

    private func present(_ vc: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .fade
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension LoadingViewController: StreamSetupDelegate {
    func streamSetupCompleted(_ streamPlayer: StreamPlayer) {
        presentPlayerViewController(streamPlayer: streamPlayer)
    }

    func streamSetupFailed() {
        presentInitialConfiguration()
    }
}
