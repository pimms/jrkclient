import CoreData

enum CoreDataStackError: Error {
    case castFailure
}

protocol CoreDataStackProtocol {
    var managedObjectContext: NSManagedObjectContext { get }
}

// MARK: - Internal methods

extension CoreDataStackProtocol {

    // MARK: - Fetching

    func fetch<T: NSManagedObject>(_ what: T.Type, completion: @escaping ([T]?, Error?) -> Void) {
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
