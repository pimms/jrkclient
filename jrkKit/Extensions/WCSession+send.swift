import Foundation
import WatchConnectivity

public extension WCSession {
    func send(_ watchPayload: WatchPayload,
              replyHandler: (([String : Any]) -> Void)? = nil,
              errorHandler: ((Error) -> Void)? = nil) {
        sendMessage(watchPayload.asDictionary(), replyHandler: replyHandler, errorHandler: errorHandler)
    }
}
