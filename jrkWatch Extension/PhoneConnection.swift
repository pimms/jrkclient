import Foundation
import WatchConnectivity
import jrkKitWatch

class PhoneConnection: NSObject {
    private lazy var log = Log(for: self)
    private let session = WCSession.default

    override init() {
        super.init()
        session.delegate = self
    }

    func activate() {
        session.activate()
    }

    private func sayHello() {
        guard session.isReachable else { return }
        log.log("Saying hello")
        session.sendMessage(["message": "hello to you too"],
                            replyHandler: nil,
                            errorHandler: nil)
    }
}

extension PhoneConnection: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.log("Session activated with state: \(activationState.rawValue)")
        sayHello()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let state = NowPlayingState(fromDictionary: message) {
            log.log("Received NowPlayingState: \(state)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        log.log("Received message (reply required): \(message)")
        replyHandler([:])
    }
}
