import Foundation

public class WatchPayloadDecoder {
    private let types: [WatchPayload.Type] = [
        NowPlayingState.self,
        ServerState.self
    ]

    public init() { }

    public func decodePayload(_ dict: [String: Any]) -> WatchPayload? {
        for type in types {
            if let instance = type.init(jsonDictionary: dict) {
                return instance
            }
        }

        return nil
    }
}
