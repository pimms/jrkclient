import CoreData

extension NSManagedObject {
    var uriRepresentation: URL {
        return objectID.uriRepresentation()
    }
}
