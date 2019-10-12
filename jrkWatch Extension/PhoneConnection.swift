import Foundation
import WatchConnectivity
import jrkKitWatch

class PhoneConnection: NSObject {
    let session = WCSession.default

    private lazy var log = Log(for: self)
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
        guard let _ = payloadDecoder.decodePayload(message) else {
            log.log(.warn, "Received unparsable message (reply required): \(message)")
            replyHandler([:])
            return
        }

        replyHandler([:])
    }
}
