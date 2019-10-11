import Foundation
import WatchConnectivity
import jrkKitWatch

protocol ServerStateDelegate: AnyObject {
    func phoneConnection(_ connection: PhoneConnection, shouldRequestDataForServerState serverState: ServerState) -> Bool
}

class PhoneConnection: NSObject {
    let session = WCSession.default
    weak var serverStateDelegate: ServerStateDelegate?

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
        guard let payload = payloadDecoder.decodePayload(message) else {
            replyHandler([:])
            return
        }

        if let serverState = payload as? ServerState {
            onServerStateReceived(serverState, replyHandler: replyHandler)
        } else {
            log.log("Received unparsable message (reply required): \(message)")
            replyHandler([:])
        }
    }
}

// MARK: - Message handling

extension PhoneConnection {
    private func onServerStateReceived(_ serverState: ServerState, replyHandler: @escaping ([String : Any]) -> Void) {
        let needData = serverStateDelegate?.phoneConnection(self, shouldRequestDataForServerState: serverState) ?? false
        log.log("ServerState received — need server data refresh: \(needData)")
        replyHandler(["needServerData": needData])
    }
}
