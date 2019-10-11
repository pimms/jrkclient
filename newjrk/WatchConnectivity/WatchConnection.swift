import Foundation
import WatchConnectivity
import jrkKit

class WatchConnection: NSObject {
    static func createConnection() -> WatchConnection? {
        guard WCSession.isSupported() else {
            return nil
        }

        let session = WCSession.default
        return WatchConnection(session: session)
    }

    // MARK: - Internal properties

    var streamPlayer: StreamPlayer? {
        didSet {
            streamPlayer?.addDelegate(self)
            sendServerStateIfNeeded()
        }
    }

    // MARK: - Private properties

    private lazy var log = Log(for: self)
    private let session: WCSession
    private var serverStateSender: ServerStateSender

    // MARK: - Private methods

    private init(session: WCSession) {
        self.session = session
        self.serverStateSender = ServerStateSender(session: session)
        super.init()

        session.delegate = self
        session.activate()
    }

    private func isConnected() -> Bool {
        return session.activationState == .activated && session.isPaired && session.isWatchAppInstalled
    }

    private func sendServerStateIfNeeded() {
        serverStateSender.sendIfNeeded(forPlayer: streamPlayer)
    }
}

extension WatchConnection: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        log.log("Session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        log.log("Session deactivated")
        serverStateSender.sessionDidDeactivate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.log("Session activation completed with state '\(activationState.rawValue)'")
        if activationState == .activated {
            sendServerStateIfNeeded()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        log.log("Received message (no reply required): \(message)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        log.log("Received message (reply required): \(message)")
        replyHandler([:])
    }
}

extension WatchConnection: StreamPlayerDelegate {
    func streamPlayerChangedState(_ streamPlayer: StreamPlayer) {
        guard isConnected() else { return }

        let payload = NowPlayingState(from: streamPlayer)
        session.send(payload)
    }
}
