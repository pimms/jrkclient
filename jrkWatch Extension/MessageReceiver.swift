import Foundation
import WatchConnectivity
import jrkKitWatch

protocol MessageReceiverDelegate: AnyObject {
    func messageReceiver(_ messageReceiver: MessageReceiver, didReceiveNowPlayingState nowPlaying: NowPlayingState)
    func messageReceiverDidReceiveApplicationContext(_ messageReceiver: MessageReceiver)
}

class MessageReceiver: NSObject {
    weak var delegate: MessageReceiverDelegate?

    private let session: WCSession
    private let payloadDecoder = WatchPayloadDecoder()
    private lazy var log = Log(for: self)

    required init(session: WCSession) {
        self.session = session
        super.init()
        self.session.delegate = self
    }
}

extension MessageReceiver: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.log("Session activated with state: \(activationState.rawValue)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let payload = payloadDecoder.decodePayload(message) {
            if let nowPlaying = payload as? NowPlayingState {
                delegate?.messageReceiver(self, didReceiveNowPlayingState: nowPlaying)
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

    func session(_: WCSession, didReceiveApplicationContext _: [String : Any]) {
        delegate?.messageReceiverDidReceiveApplicationContext(self)
    }
}
