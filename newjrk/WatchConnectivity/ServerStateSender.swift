import Foundation
import WatchConnectivity
import jrkKit

class ServerStateSender {
    private let session: WCSession

    private var hasSent = false

    init(session: WCSession) {
        self.session = session
    }

    func sendIfNeeded(forPlayer player: StreamPlayer?) {
        guard !hasSent else { return }
        guard let url = player?.serverConfiguration.url else { return }

        let payload = ServerState(rootUrl: url)
        session.send(payload, replyHandler: { [weak self] _ in
            self?.hasSent = true
        })
    }

    func sessionDidDeactivate() {
        hasSent = false
    }
}
