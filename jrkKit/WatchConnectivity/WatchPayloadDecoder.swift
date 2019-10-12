import Foundation

public class WatchPayloadDecoder {
    private let types: [WatchPayload.Type] = [
        NowPlayingState.self,
        StreamPictureRequest.self,
        StreamPictureResponse.self,
    ]

    public init() { }

    public func decodePayload(_ dict: [String: Any]) -> WatchPayload? {
        for type in types {
            let className = String(describing: type)
            if let subDict = dict[className] as? [String: Any] {
                if let instance = type.init(fromDictionary: subDict) {
                    return instance
                }
            }
        }

        return nil
    }
}
