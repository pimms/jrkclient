import UIKit
import jrkKitTV

class RootStateController: UIViewController {
    private lazy var log = Log(for: self)
    private let dataStack: CoreDataStackProtocol = CoreDataStack()
    private var streamPlayer: StreamPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataStack.setup { [weak self] in
            self?.attemptServerSetup()
        }
    }

    private func attemptServerSetup() {
        log.log("Attempting to connect to existing server configuration")
        if  let preferredConfiguration = dataStack.preferredServerConfiguration(),
            let networkClient = setupNetworkClient(withConfiguration: preferredConfiguration)
        {
            let apiClient = ApiClient(networkClient: networkClient)
            apiClient.loadRootDocument { [weak self] error in
                guard error == nil else {
                    self?.handleConnectionError(error)
                    return
                }

                self?.log.log("Successfully connected to existing configuration")
                let streamPlayer = StreamPlayer(serverConfiguration: preferredConfiguration, apiClient: apiClient)
                self?.streamPlayer = streamPlayer

                fatalError("oooooopsies")
            }
        } else {
            log.log("No configuration exists")
            setupNewConfiguration()
        }
    }

    private func setupNetworkClient(withConfiguration config: ServerConfiguration) -> NetworkClientProtocol? {
        guard let rootUrl = config.url else {
            log.log(.error, "Unable to setup NetworkClient from server configuration: \(config)")
            return nil
        }

        return NetworkClient(rootURL: rootUrl)
    }

    private func setupNewConfiguration() {
        let setupViewController = SetupViewController(dataStack: dataStack)
        setupViewController.delegate = self
        add(setupViewController)
    }
}

extension RootStateController {
    private func handleConnectionError(_ error: Error?) {
        let title = "Failed to connect to existing configuration"

        let message: String
        if let errorString = error as? String {
            message = "Error: \(errorString)"
        } else {
            message = "Unknown error\(error == nil ? "" : " (\(error!))")"
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Try again", style: .default, handler: { [weak self] _ in
            self?.attemptServerSetup()
        }))
        alertController.addAction(UIAlertAction(title: "Delete configuration", style: .destructive, handler: { [weak self] _ in
            self?.dataStack.removePreferredServerConfiguration()
            self?.attemptServerSetup()
        }))
        present(alertController, animated: true)
    }
}

extension RootStateController: SetupViewControllerDelegate {
    func setupViewController(_ vc: SetupViewController, initializedPlayer player: StreamPlayer) {
        self.streamPlayer = player
        self.remove(vc)
        attemptServerSetup()
    }
}
