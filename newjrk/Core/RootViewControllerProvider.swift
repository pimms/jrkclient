import UIKit

class RootViewControllerProvider {
    private let dataStack: CoreDataStackProtocol

    init(dataStack: CoreDataStackProtocol) {
        self.dataStack = dataStack
    }

    // MARK: - Internal methods

    func createRootViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        if let preferredConfiguration = dataStack.preferredServerConfiguration() {
            fatalError("TODO: Initiate a VC with a defined configuration: \(preferredConfiguration)")
        }

        return storyboard.instantiateViewController(identifier: "InitialConfigViewController")
    }
}
