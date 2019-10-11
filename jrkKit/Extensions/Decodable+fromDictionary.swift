import Foundation

public extension Decodable {
    init?(jsonDictionary: [String: Any]) {
        let decoder = JSONDecoder()

        guard let data = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: []) else {
            return nil
        }

        guard let result = try? decoder.decode(Self.self, from: data) else {
            return nil
        }

        self = result
    }
}
