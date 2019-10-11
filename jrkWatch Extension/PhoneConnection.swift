import Foundation
import WatchConnectivity
import jrkKitWatch

class PhoneConnection: NSObject {
    private lazy var log = Log(for: self)
    private let session = WCSession.default
    private let payloadDecoder = WatchPayloadDecoder()

    override init() {
        super.init()
        session.delegate = self
    }

    func activate() {
        session.activate()
    }
}

extension PhoneConnection: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.log("Session activated with state: \(activationState.rawValue)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let payload = payloadDecoder.decodePayload(message) {
            if let nowPlaying = payload as? NowPlayingState {
                log.log("TODO: Handle NowPlayingState update: \(nowPlaying)")
            }
        } else {
            log.log("Received unparsable message (no reply required): \(message)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let payload = payloadDecoder.decodePayload(message) {
            log.log("Received WatchPayload (reply required): \(payload)")
        } else {
            log.log("Received message (reply required): \(message)")
        }
        replyHandler([:])
    }
}
