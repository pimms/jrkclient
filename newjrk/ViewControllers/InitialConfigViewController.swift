import UIKit

class InitialConfigViewController: UIViewController {
    private enum ConfigError: String, Error {
        case rootDocumentFailure = "Failed to load the root document of the specified server."
        case coreDataFailure = "Failed to get a handle to the Core Data stack."
        case serverConfigCreationError = "Failed to create a ServerConfiguration instance."
        case serverSetupError = "Failed to perform initial server setup."
        case unknownError = "Uknown error"
        case notImplementedYet = "TODO!"
    }

    @IBOutlet private var urlField: UITextField?
    @IBOutlet private var errorLabel: UILabel?

    private lazy var dataStack = AppDelegate.shared.coreDataStack
    private var loadingView: LoadingView? { didSet { oldValue?.remove() } }
    private var serverSetup: ServerSetup?

    override func viewDidLoad() {
        super.viewDidLoad()

        #if !targetEnvironment(macCatalyst)
        urlField?.becomeFirstResponder()
        #endif
    }

    @IBAction private func submitButtonTapped() {
        _ = attemptSubmit()
    }

    private func attemptSubmit() -> Bool {
        let convertResult = URLValidator.convertToURL(urlField?.text)

        switch convertResult {
        case .failure(let err):
            displayError(err)
            animateErrorLabel()
            return false
        case .success(let url):
            submit(url: url)
            return true
        }
    }

    private func submit(url: URL) {
        loadingView = LoadingView.show(in: self, withMessage: "Connecting...")
        urlField?.resignFirstResponder()

        let networkClient = NetworkClient(rootURL: url)
        let apiClient = ApiClient(networkClient: networkClient)

        apiClient.loadRootDocument { [weak self] error in
            guard error == nil else {
                self?.handleSetupError(ConfigError.rootDocumentFailure)
                return
            }

            guard let dataStack = self?.dataStack else {
                self?.handleSetupError(ConfigError.coreDataFailure)
                return
            }

            guard let serverConfig = self?.createServerConfig(fromUrl: url) else {
                self?.handleSetupError(ConfigError.serverConfigCreationError)
                return
            }

            self?.serverSetup = ServerSetup(apiClient: apiClient, dataStack: dataStack, serverConfig: serverConfig)
            self?.serverSetup?.performInitialSetup { error in
                guard error == nil else {
                    self?.handleSetupError(ConfigError.serverSetupError)
                    return
                }

                self?.handleSetupCompleted(serverConfig: serverConfig, apiClient: apiClient)
            }
        }
    }

    private func createServerConfig(fromUrl url: URL) -> ServerConfiguration? {
        let serverConfig = dataStack.createEntity(ServerConfiguration.self)
        serverConfig.url = url
        return serverConfig
    }

    private func handleSetupCompleted(serverConfig: ServerConfiguration, apiClient: ApiClient) {
        loadingView?.remove()

        guard
            let player = AppDelegate.shared.streamPlayer,
            dataStack.save()
        else { return }

        dataStack.setPreferredServerConfiguration(serverConfig)

        let playerVc = UIStoryboard.instantiate(PlayerViewController.self)
        playerVc.setup(streamPlayer: player)
        navigationController?.setViewControllers([playerVc], animated: true)
    }

    private func handleSetupError(_ error: Error?) {
        loadingView?.remove()
        UIAlertController.display(error: error, withTitle: "Setup Failure", message: "Failed to connect to server", in: self)
    }
}

// MARK: - UITextFieldDelegate

extension InitialConfigViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return attemptSubmit()
    }
}

// MARK: - Input validation

extension InitialConfigViewController {
    private func displayError(_ error: Error) {
        let error = (error as? String) ?? ConfigError.unknownError.rawValue
        errorLabel?.text = error
        view.layoutIfNeeded()
    }

    private func animateErrorLabel() {
        let sourceTransform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        errorLabel?.alpha = 0
        errorLabel?.transform = sourceTransform
        errorLabel?.layer.removeAllAnimations()

        UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseOut, animations: {
            self.errorLabel?.transform = CGAffineTransform.identity
            self.errorLabel?.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: nil)

        UIView.animate(withDuration: 0.3, delay: 3, options: .curveEaseOut, animations: {
            self.errorLabel?.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
