import Foundation

extension Decodable {
    static func decoded(fromJson data: Data) -> Self? {
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: data)
    }

    static func decodedArray(fromJson data: Data) -> [Self]? {
        let decoder = JSONDecoder()
        return try? decoder.decode([Self].self, from: data)
    }
}
