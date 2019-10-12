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
            updateApplicationContext()
        }
    }

    // MARK: - Private properties

    private lazy var log = Log(for: self)
    private let session: WCSession
    private let payloadDecoder = WatchPayloadDecoder()

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

    private func updateApplicationContext() {
        guard let currentUrl = streamPlayer?.serverConfiguration.url?.absoluteString else {
            log.log(.error, "Could not update Application Context: no URL defined")
            return
        }

        if let existingContext = ApplicationContext(fromDictionary: session.receivedApplicationContext), existingContext.url == currentUrl {
            return
        }

        log.log("Updating Application Context")
        let currentContext = ApplicationContext(url: currentUrl)

        do {
            try session.updateApplicationContext(currentContext.asDictionary())
        } catch {
            log.log(.error, "Failed to update ApplicationContext: \(error.localizedDescription)")
        }
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

        if let watchPayload = payloadDecoder.decodePayload(message) {
            if let pictureRequest = watchPayload as? StreamPictureRequest {
                handleStreamPictureRequest(pictureRequest, replyHandler: replyHandler)
            } else {
                log.log(.warn, "Unhandled WatchPayload: \(watchPayload)")
            }
        }

        replyHandler([:])
    }
}

// MARK: - Message Handling

extension WatchConnection {
    private func handleStreamPictureRequest(_ request: StreamPictureRequest, replyHandler: @escaping ([String : Any]) -> Void) {

        guard
            let scaledImage = streamPlayer?.streamPicture?.scaledForWatch(),
            let imageData = scaledImage.jpegData(compressionQuality: 0)
        else {
            log.log(.error, "Failed to create watch-scaled image data")
            replyHandler([:])
            return
        }

        log.log("Successfully responding to stream picture request")
        let response = StreamPictureResponse(imageData: imageData)
        let dictionary = response.asDictionary()
        replyHandler(dictionary)
    }
}

// MARK: - StreamPlayerDelegate

extension WatchConnection: StreamPlayerDelegate {
    func streamPlayerChangedState(_ streamPlayer: StreamPlayer) {
        guard isConnected() else { return }

        let payload = NowPlayingState(from: streamPlayer)
        session.send(payload)
    }
}
