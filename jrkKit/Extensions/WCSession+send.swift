#if !os(tvOS)
import Foundation
import WatchConnectivity

public extension WCSession {
    func send(_ watchPayload: WatchPayload,
              replyHandler: (([String : Any]) -> Void)? = nil,
              errorHandler: ((Error) -> Void)? = nil) {
        sendMessage(watchPayload.encodeWatchPayload(), replyHandler: replyHandler, errorHandler: errorHandler)
    }
}
#endif
