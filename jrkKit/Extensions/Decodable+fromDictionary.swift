import Foundation

public extension Decodable {
    init?(fromDictionary dict: [String: Any]) {
        let decoder = JSONDecoder()

        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return nil
        }

        guard let result = try? decoder.decode(Self.self, from: data) else {
            return nil
        }

        self = result
    }
}
