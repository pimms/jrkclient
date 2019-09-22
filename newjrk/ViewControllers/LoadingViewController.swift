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
        attemptConnection()
    }

    // MARK: - Private methods

    private func attemptConnection() {
        let dataStack = AppDelegate.shared.coreDataStack
        if  let preferredConfiguration = dataStack.preferredServerConfiguration(),
            let networkClient = setupNetworkClient(withConfiguration: preferredConfiguration)
        {
            activityIndicator?.startAnimating()
            UIView.animate(withDuration: 0.2) { self.activityIndicator?.alpha = 1 }

            let apiClient = ApiClient(networkClient: networkClient)
            apiClient.loadRootDocument { [weak self] error in
                if let error = error {
                    self?.handleCriticalError(error)
                } else {
                    self?.presentPlayerViewController(withServerConfiguration: preferredConfiguration, apiClient: apiClient)
                }
            }
        } else {
            presentInitialConfiguration()
        }
    }

    private func presentInitialConfiguration() {
        let vc = UIStoryboard.instantiate(InitialConfigViewController.self)
        present(vc)
    }

    private func presentPlayerViewController(withServerConfiguration serverConfiguration: ServerConfiguration, apiClient: ApiClient) {
        let vc = UIStoryboard.instantiate(PlayerViewController.self)
        vc.setup(withServerConfiguration: serverConfiguration, apiClient: apiClient)
        present(vc)
    }

    private func present(_ vc: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .fade
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: false)
    }


    private func setupNetworkClient(withConfiguration config: ServerConfiguration) -> NetworkClientProtocol? {
        guard let rootUrl = config.url else {
            self.handleCriticalError(LoadingError.rootUrlMissing)
            return nil
        }

        return NetworkClient(rootURL: rootUrl)
    }


    private func handleCriticalError(_ error: Error?) {
        UIAlertController.display(error: error, withTitle: "Critical Error", message: "Unable to load stream.", in: self) { [weak self] in
            self?.attemptConnection()
        }
    }
}
