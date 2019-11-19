import UIKit
import jrkKitTV

protocol SetupViewControllerDelegate: AnyObject {
    func setupViewController(_ vc: SetupViewController, initializedPlayer player: StreamPlayer)
}

class SetupViewController: UIViewController {
    private enum ConfigError: String, Error {
        case rootDocumentFailure = "Failed to load the root document of the specified server."
        case coreDataFailure = "Failed to get a handle to the Core Data stack."
        case serverConfigCreationError = "Failed to create a ServerConfiguration instance."
        case serverSetupError = "Failed to perform initial server setup."
        case unknownError = "Uknown error"
        case notImplementedYet = "TODO!"
    }

    // MARK: - Internal properties

    weak var delegate: SetupViewControllerDelegate?

    // MARK: - Private properties

    private let dataStack: CoreDataStackProtocol
    private var serverSetup: ServerSetup?

    // MARK: - UI properties

    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Enter a JRK URL"
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Connect", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .primaryActionTriggered)
        return button
    }()

    // MARK: - Init

    required init?(coder: NSCoder) {
        fatalError()
    }

    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }

    required init(dataStack: CoreDataStackProtocol) {
        self.dataStack = dataStack
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.addSubview(label)
        view.addSubview(textField)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -64),

            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 64),
            button.widthAnchor.constraint(equalTo: textField.widthAnchor),
        ])
    }

    // MARK: - Private methods

    @objc private func buttonClicked() {
        let result = URLValidator.convertToURL(textField.text)
        switch result {
        case .failure(let error):
            displayError(error)
        case .success(let url):
            configure(withUrl: url)
        }
    }

    private func configure(withUrl url: URL) {
        let networkClient = NetworkClient(rootURL: url)
        let apiClient = ApiClient(networkClient: networkClient)

                apiClient.loadRootDocument { [weak self] error in
            guard error == nil else {
                self?.displayError(ConfigError.rootDocumentFailure)
                return
            }

            guard let dataStack = self?.dataStack else {
                self?.displayError(ConfigError.coreDataFailure)
                return
            }

            guard let serverConfig = self?.createServerConfig(fromUrl: url) else {
                self?.displayError(ConfigError.serverConfigCreationError)
                return
            }

            self?.serverSetup = ServerSetup(apiClient: apiClient, dataStack: dataStack, serverConfig: serverConfig)
            self?.serverSetup?.performInitialSetup { result in
                switch result {
                case .failure(let error):
                    self?.displayError(error)
                case .success(let streamPlayer):
                    self?.handleSetupCompleted(streamPlayer: streamPlayer, serverConfig: serverConfig, apiClient: apiClient)
                }
            }
        }
    }

    private func createServerConfig(fromUrl url: URL) -> ServerConfiguration? {
        let serverConfig = dataStack.createEntity(ServerConfiguration.self)
        serverConfig.url = url
        return serverConfig
    }

    private func handleSetupCompleted(streamPlayer: StreamPlayer, serverConfig: ServerConfiguration, apiClient: ApiClient) {
        guard dataStack.save() else { return }
        dataStack.setPreferredServerConfiguration(serverConfig)
        delegate?.setupViewController(self, initializedPlayer: streamPlayer)
    }
}

extension SetupViewController {
    private func displayError(_ error: Error) {
        let message = (error as? String) ?? "Unknown error"
        let alert = UIAlertController(title: "Invalid URL", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
