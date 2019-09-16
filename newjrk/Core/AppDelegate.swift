import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to fetch the shared AppDelegate instance")
        }

        return delegate
    }

    /// TODO: The data stack should either be an instance of the SceneDelegate, or the whole
    /// application should NOT support multiple scenes. Currently, we may enter into foul ball
    /// country if the user opens multiple scenes.
    lazy var coreDataStack: CoreDataStackProtocol = CoreDataStack()
    var streamPlayer: StreamPlayer?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
}

