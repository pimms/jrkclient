import CoreData

class CoreDataStack: CoreDataStackProtocol {
    // MARK: - Internal properties

    var managedObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Private properties
    private lazy var persistentContainer: NSPersistentCloudKitContainer! = {
        let container = NSPersistentCloudKitContainer(name: "newjrk")
        return container
    }()

    // MARK: - Setup

    init(completion: (() -> Void)? = nil) {
        setup {
            completion?()
        }
    }

    private func setup(completion: @escaping () -> Void) {
        persistentContainer.loadPersistentStores(completionHandler: { desc, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }

            completion()
        })
    }
}
