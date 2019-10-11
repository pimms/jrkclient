import CoreData

public class CoreDataStack: CoreDataStackProtocol {

    // MARK: - Public properties

    public var managedObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Private properties

    private lazy var persistentContainer: NSPersistentCloudKitContainer! = {
        let bundle = Bundle(for: type(of: self))
        guard
            let modelUrl = bundle.url(forResource: "newjrk", withExtension: "momd"),
            let objectModel = NSManagedObjectModel(contentsOf: modelUrl)
        else { fatalError() }

        let container = NSPersistentCloudKitContainer(name: "newjrk", managedObjectModel: objectModel)
        return container
    }()

    // MARK: - Setup

    public init(completion: (() -> Void)? = nil) {
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
