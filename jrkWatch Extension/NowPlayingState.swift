import Foundation
import jrkKitWatch

struct NowPlayingState {
    let title: String
    let season: String
    let playerState: PlayerState

    init?(fromDictionary dict: [String: Any]) {
        guard
            let title = dict["title"] as? String,
            let season = dict["season"] as? String,
            let stateString = dict["playerState"] as? String,
            let playerState = PlayerState(rawValue: stateString)
        else {
            return nil
        }

        self.title = title
        self.season = season
        self.playerState = playerState
    }
}
