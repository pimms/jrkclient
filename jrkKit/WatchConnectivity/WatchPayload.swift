import Foundation

public protocol WatchPayload: Codable { }

extension WatchPayload {
    func encodeWatchPayload() -> [String: Any] {
        let className = String(describing: Self.self)
        let payload = asDictionary()

        return [ className: payload ]
    }
}

// MARK: - NowPlayingState

public struct NowPlayingState: WatchPayload {
    public let title: String
    public let season: String
    public let playerState: PlayerState

    public init(title: String, season: String, playerState: PlayerState) {
        self.title = title
        self.season = season
        self.playerState = playerState
    }

    public init(from player: StreamPlayer) {
        title = player.nowPlaying?.name ?? "JRK"
        season = player.nowPlaying?.season ?? "???"
        playerState = player.state
    }
}

// MARK: - InitialConfiguration

public struct ServerState: WatchPayload {
    public let rootUrl: String

    public init(rootUrl: URL) {
        self.rootUrl = rootUrl.absoluteString
    }
}
