@testable import newjrk
import Foundation
import CoreData
import XCTest

class TestDataStack: CoreDataStackProtocol {
    let managedObjectContext: NSManagedObjectContext

    init() {
        let lock = NSRecursiveLock()
        lock.lock()

        let container = try! PersistentContainer.container(named: "newjrk")
        var tempMoc: NSManagedObjectContext?

        container.loadPersistentStores { desc, error in
            tempMoc = container.viewContext
            lock.unlock()
        }

        lock.lock()

        guard let moc = tempMoc else {
            fatalError("Failed to initialize NSManagedObjectContext")
        }

        managedObjectContext = moc
    }
}

/// We need to cache the NSManagedObjectModel between test executions.
/// See answer here: https://stackoverflow.com/a/51857486
fileprivate class PersistentContainer {
    enum CoreDataError: Error {
        case modelURLNotFound(forResourceName: String)
        case modelLoadingFailed(forURL: URL)
    }

    private static var _model: NSManagedObjectModel?
    private static func model(name: String) throws -> NSManagedObjectModel {
        if _model == nil {
            _model = try loadModel(name: name, bundle: Bundle.main)

        }

        return _model!
    }

    private static func loadModel(name: String, bundle: Bundle) throws -> NSManagedObjectModel {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
            throw CoreDataError.modelURLNotFound(forResourceName: name)
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataError.modelLoadingFailed(forURL: modelURL)
       }
        return model
    }

    public static func container(named name: String) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name, managedObjectModel: try model(name: name))

        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let path = docDir.appendingPathComponent("cdUnitTest.store")
        let desc = NSPersistentStoreDescription(url: path)
        desc.configuration = "UnitTest"
        container.persistentStoreDescriptions = [ desc ]

        return container
    }
}
