import CoreData

enum CoreDataStackError: Error {
    case castFailure
}

protocol CoreDataStackProtocol {
    var managedObjectContext: NSManagedObjectContext { get }
}

// MARK: - Persistence actions

extension CoreDataStackProtocol {

    // MARK: - Fetching

    func fetch<T: NSManagedObject>(_: T.Type, completion: @escaping ([T]?, Error?) -> Void) {
        let request = T.fetchRequest()

        do {
            let result = try managedObjectContext.fetch(request)
            guard let fetchedObjects = result as? [T] else {
                completion(nil, CoreDataStackError.castFailure)
                return
            }

            completion(fetchedObjects, nil)
        } catch {
            completion(nil, error)
            return
        }
    }

    func fetch<T: NSManagedObject>(_: T.Type, byURIRepresentation uri: URL) -> T? {
        guard
            let objectId = managedObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri),
            let object = managedObjectContext.object(with: objectId) as? T else {
            return nil
        }

        return object
    }

    // MARK: - Entity Creation

    func createEntity<T: NSManagedObject>() -> T {
        return createEntity(T.self)
    }

    func createEntity<T: NSManagedObject>(_: T.Type) -> T {
        let entityName = T.description()
        guard let description = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext) else {
            fatalError("Failed to create NSEntityDescription for type: '\(entityName)'")
        }

        let entity = T(entity: description, insertInto: managedObjectContext)
        return entity
    }

    // MARK: - Persistence

    @discardableResult
    func save() -> Bool {
        do {
            try managedObjectContext.save()
            return true
        } catch {
            print("Failed to persist NSManagedObjectContext: \(error)")
            return false
        }
    }
}

// MARK: - Preferred Server Configuration

extension CoreDataStackProtocol {

    private var preferredServerConfigurationKey: String { "preferredServerConfigurationId" }

    func setPreferredServerConfiguration(_ serverConfiguration: ServerConfiguration) {
        UserDefaults.standard.setValue(serverConfiguration.uriRepresentation.absoluteString,
                                       forKey: preferredServerConfigurationKey)
    }

    func preferredServerConfiguration() -> ServerConfiguration? {
        guard
            let uriString = UserDefaults.standard.value(forKey: preferredServerConfigurationKey) as? String,
            let uri = URL(string: uriString),
            let config = fetch(ServerConfiguration.self, byURIRepresentation: uri)
        else {
            UserDefaults.standard.removeObject(forKey: preferredServerConfigurationKey)
            return nil
        }

        return config
    }
}
