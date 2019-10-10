import Foundation

struct RootDTO: Decodable {
    let streamName: String
    let streamPicture: String
    let playlist: String
    let nowPlaying: String
    let episodeLog: String
    let eventLog: String
}

