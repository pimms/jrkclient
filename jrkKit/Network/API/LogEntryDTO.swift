import Foundation

public struct LogEntryDTO: Decodable {
    public let title: String?
    public let description: String?
    public let timestamp: String
}

