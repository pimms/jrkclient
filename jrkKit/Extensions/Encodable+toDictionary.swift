import Foundation

public extension Encodable {
    func asDictionary() -> [String: Any] {
        guard
            let data = try? JSONEncoder().encode(self),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else {
            fatalError("Failed to serialize Encodable (\(String(describing: Self.self))) as dictionary")
        }
        return dictionary
    }
}
