import Foundation

public struct RootDTO: Decodable {
    public let streamName: String
    public let streamPicture: String
    public let playlist: String
    public let nowPlaying: String
    public let episodeLog: String
    public let eventLog: String
}

