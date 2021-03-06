import UIKit
import CoreData
import jrkKit

protocol StreamSetupDelegate: class {
    func streamSetupCompleted(_ streamPlayer: StreamPlayer)
    func streamSetupFailed()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var shared: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to fetch the shared AppDelegate instance")
        }

        return delegate
    }

    private enum StreamSetupState {
        case notStarted
        case success
        case failed
    }

    // MARK: - Internal properties

    /// TODO: The data stack should either be an instance of the SceneDelegate, or the whole
    /// application should NOT support multiple scenes. Currently, we may enter into foul ball
    /// country if the user opens multiple scenes.
    lazy var coreDataStack: CoreDataStackProtocol = CoreDataStack()

    var streamPlayer: StreamPlayer? {
        didSet {
            oldValue?.pause()
            streamSetupState = streamPlayer == nil ? .notStarted : .success
            watchConnection?.streamPlayer = streamPlayer
        }
    }

    // MARK: - Private properties

    private lazy var log = Log(for: self)
    private var streamSetupState: StreamSetupState = .notStarted
    private let delegates = DelegateCollection<StreamSetupDelegate>()
    private let watchConnection = WatchConnection.createConnection()

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let isRunningTests = UserDefaults.standard.bool(forKey: "isRunningUnitTests")
        if !isRunningTests {
            coreDataStack.setup { [weak self] in
                self?.attemptServerSetup()
            }
        }

        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        }

        return .all
    }
}

extension AppDelegate {
    private func attemptServerSetup() {
        log.log("Attempting to connect to existing server configuration")
        if  let preferredConfiguration = coreDataStack.preferredServerConfiguration(),
            let networkClient = setupNetworkClient(withConfiguration: preferredConfiguration)
        {
            let apiClient = ApiClient(networkClient: networkClient)
            apiClient.loadRootDocument { [weak self] error in
                if error == nil {
                    self?.log.log("Successfully connected to existing configuration")
                    self?.streamPlayer = StreamPlayer(serverConfiguration: preferredConfiguration, apiClient: apiClient)
                    self?.streamSetupState = .success
                } else {
                    self?.log.log(.error, "Failed to load root document")
                    self?.streamSetupState = .failed
                }
                self?.notifyStreamSetupDelegates()
            }
        } else {
            log.log("No configuration exists")
            streamSetupState = .failed
            notifyStreamSetupDelegates()
        }
    }

    private func setupNetworkClient(withConfiguration config: ServerConfiguration) -> NetworkClientProtocol? {
        guard let rootUrl = config.url else {
            log.log(.error, "")
            return nil
        }

        return NetworkClient(rootURL: rootUrl)
    }
}

extension AppDelegate {
    func addStreamSetupDelegate(_ delegate: StreamSetupDelegate) {
        delegates.add(delegate)
        notifyStreamSetupDelegate(delegate)
    }

    private func notifyStreamSetupDelegates() {
        delegates.invoke { self.notifyStreamSetupDelegate($0) }
    }

    private func notifyStreamSetupDelegate(_ delegate: StreamSetupDelegate?) {
        switch streamSetupState {
        case .failed:
            delegate?.streamSetupFailed()
        case .success:
            if let player = streamPlayer {
                delegate?.streamSetupCompleted(player)
            }
        default:
            break
        }
    }
}
