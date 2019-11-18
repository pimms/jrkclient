import UIKit
import jrkKitTV

class RootStateController: UIViewController {
    private let dataStack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataStack.setup {
            if let serverConfig = self.dataStack.preferredServerConfiguration() {
                self.setupExistingConfiguration(serverConfig)
            } else {
                self.setupNewConfiguration()
            }
        }
    }

    private func setupExistingConfiguration(_ configuration: ServerConfiguration) {
        fatalError("TODO! Server configuration exists!")
    }

    private func setupNewConfiguration() {
        let setupViewController = SetupViewController(dataStack: dataStack)
        add(setupViewController)
    }
}

