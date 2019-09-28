import Foundation

struct NowPlayingDTO: Decodable, Equatable {
    let season: String
    let name: String
    let key: String
}
