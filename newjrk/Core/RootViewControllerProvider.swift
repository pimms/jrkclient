import UIKit

class RootViewControllerProvider {
    private let dataStack: CoreDataStackProtocol

    init(dataStack: CoreDataStackProtocol) {
        self.dataStack = dataStack
    }

    // MARK: - Internal methods

    func createRootViewController() -> UIViewController {
        if let playerVc = createPlayerViewControllerIfPossible() {
            return playerVc
        }

        return createInitialConfigurationViewController()
    }

    // MARK: - Private methods

    private func createPlayerViewControllerIfPossible() -> UIViewController? {
        if let preferredConfiguration = dataStack.preferredServerConfiguration() {
            let playerVc = UIStoryboard.instantiate(PlayerViewController.self)
            playerVc.setup(withServerConfiguration: preferredConfiguration)
            return playerVc
        }

        return nil
    }

    private func createInitialConfigurationViewController() -> UIViewController {
        let rootViewController = UIStoryboard.instantiate(InitialConfigViewController.self)
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }
}
