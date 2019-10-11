import Foundation
import WatchConnectivity
import UIKit
import jrkKit

class ServerStateSender {
    private let session: WCSession
    private var hasSent = false

    private lazy var log = Log(for: self)

    init(session: WCSession) {
        self.session = session
    }

    func sendIfNeeded(forPlayer player: StreamPlayer?) {
        guard !hasSent else { return }
        guard let player = player else { return }
        guard let url = player.serverConfiguration.url else { return }

        let payload = ServerState(rootUrl: url)
        session.send(payload, replyHandler: { [weak self] response in
            guard let self = self else { return }
            guard let needsUpdate = response["needServerData"] as? Bool else {
                self.log.log(.error, "watch did not include 'needServerData' in ServerState response")
                return
            }

            self.log.log("Watch responded with 'needServerData': \(needsUpdate)")

            if needsUpdate {
                self.hasSent = self.sendServerData(streamPlayer: player)
            } else {
                self.hasSent = true
            }
        })
    }

    func sessionDidDeactivate() {
        hasSent = false
    }

    private func sendServerData(streamPlayer: StreamPlayer) -> Bool {
        log.log("Sending server data")

        guard let url = streamPlayer.serverConfiguration.url?.absoluteString else {
            log.log(.error, "No root URL defined")
            return false
        }

        guard let image = streamPlayer.streamPicture else {
            log.log(.error, "No stream picture in StreamPlayer")
            return false
        }

        guard let scaledImage = image.scaledForWatch() else {
            log.log(.error, "Failed to scale stream picture for Watch")
            return false
        }

        guard let imageData = scaledImage.pngData() else {
            log.log(.error, "Faild to get PNG data from stream picture")
            return false
        }

        let payload = ServerData(rootUrl: url, streamImageData: imageData)
        _ = session.transferUserInfo(payload.asDictionary())
        log.log("Successfully sent server data")
        return true
    }
}
