import Foundation

public struct NowPlayingDTO: Decodable, Equatable {
    public let season: String
    public let name: String
    public let key: String
}
