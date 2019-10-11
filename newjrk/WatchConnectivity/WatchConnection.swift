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
        }
    }

    // MARK: - Private properties

    private lazy var log = Log(for: self)
    private let session: WCSession

    // MARK: - Private methods

    private init(session: WCSession) {
        self.session = session
        super.init()

        session.delegate = self
        session.activate()
    }

    private func isConnected() -> Bool {
        return session.activationState == .activated && session.isPaired && session.isWatchAppInstalled
    }

    private func sayHello() {
        guard isConnected() else { return }
        log.log("Saying hello")
        session.sendMessage(["message": "hello"],
                            replyHandler: nil,
                            errorHandler: nil)
    }
}

extension WatchConnection: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        log.log("Session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        log.log("Session deactivated")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.log("Session activation completed with state '\(activationState.rawValue)'")
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

        let title = streamPlayer.nowPlaying?.name ?? "JRK"
        let season = streamPlayer.nowPlaying?.season ?? "???"
        let state = streamPlayer.state.rawValue

        let payload = [
            "title": title,
            "season": season,
            "playerState": state
        ]

        session.sendMessage(payload, replyHandler: nil)
    }
}
