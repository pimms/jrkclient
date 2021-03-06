import CoreData

public class CoreDataStack: CoreDataStackProtocol {

    // MARK: - Public properties

    public var managedObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Private properties

    private var initialized = false
    private lazy var log = Log(for: self)

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

    public init() { }

    public init(completion: @escaping () -> Void) {
        setup {
            completion()
        }
    }

    public func setup(completion: @escaping () -> Void) {
        guard !initialized else {
            log.log(.warn, "CoreDataStack.setup() called, but instance is already initialized")
            completion()
            return
        }

        persistentContainer.loadPersistentStores(completionHandler: { desc, error in
            self.initialized = true
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }

            completion()
        })
    }
}
