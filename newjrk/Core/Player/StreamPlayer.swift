import AVFoundation

protocol StreamPlayerDelegate: AnyObject {
    func streamPlayerChangedState(_ streamPlayer: StreamPlayer)
}

class StreamPlayer: NSObject {

    // MARK: - Internal properties

    var state: PlayerState {
        if isBuffering {
            return .buffering
        }

        if player.status == .readyToPlay {
            if player.rate >= 0.99 {
                return .playing
            } else {
                return .paused
            }
        } else if player.status == .failed {
            return .failed
        }

        return .notPlaying
    }

    var streamName: String {
        return apiClient.streamName ?? "Unnamed Stream"
    }

    let serverConfiguration: ServerConfiguration
    let apiClient: ApiClient

    // MARK: - Private properties

    private lazy var log = Log(for: self)
    private let delegates = DelegateCollection<StreamPlayerDelegate>()
    private let player: AVPlayer
    private let playerItem: AVPlayerItem
    private var isBuffering = false

    // MARK: - Init

    required init?(serverConfiguration: ServerConfiguration, apiClient: ApiClient) {
        self.serverConfiguration = serverConfiguration
        self.apiClient = apiClient

        guard let url = apiClient.playlistURL else { return nil }
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        super.init()

        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    }

    // MARK: - Internal methods

    func play() {
        player.play()
        delegates.invoke { $0.streamPlayerChangedState(self) }
    }

    func pause() {
        player.pause()
        delegates.invoke { $0.streamPlayerChangedState(self) }
    }

    func addDelegate(_ delegate: StreamPlayerDelegate) {
        delegates.add(delegate)
    }

    // MARK: - Overrides

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change _: [NSKeyValueChangeKey : Any]?, context _: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            var notifyDelegates = true

            switch keyPath {
            case "playbackBufferEmpty":
                log.log("keyPath: playbackBufferEmpty")
                isBuffering = true
            case "playbackLikelyToKeepUp":
                log.log("keyPath: playbackLikelyToKeepUp")
                isBuffering = false
            case "playbackBufferFull":
                log.log("keyPath: playbackBufferFull")
                isBuffering = false
            default:
                notifyDelegates = false
                break
            }

            if notifyDelegates {
                delegates.invoke { $0.streamPlayerChangedState(self) }
            }
        }
    }

    // MARK: - Private methods
}
