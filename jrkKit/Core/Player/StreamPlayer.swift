import AVFoundation
import MediaPlayer

public protocol StreamPlayerDelegate: AnyObject {
    func streamPlayerChangedState(_ streamPlayer: StreamPlayer)
}

public class StreamPlayer: NSObject {

    // MARK: - Public properties

    public var state: PlayerState {
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

    public var streamName: String {
        return apiClient.streamName ?? "JRK"
    }

    public var episodeTitle: String {
        if let nowPlaying = nowPlaying {
            return "\(nowPlaying.name) \(nowPlaying.season)"
        }
        return "Unknown"
    }

    public let serverConfiguration: ServerConfiguration
    public let apiClient: ApiClient
    public let player: AVPlayer
    public private(set) var streamPicture: UIImage?
    public private(set) var nowPlaying: NowPlayingDTO?

    // MARK: - Private properties

    private lazy var log = Log(for: self)
    private let delegates = DelegateCollection<StreamPlayerDelegate>()
    private let playerItem: AVPlayerItem
    private var isBuffering = false

    // MARK: - Init

    public required init?(serverConfiguration: ServerConfiguration, apiClient: ApiClient) {
        self.serverConfiguration = serverConfiguration
        self.apiClient = apiClient

        guard let url = apiClient.playlistURL else { return nil }
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        super.init()

        if let path = serverConfiguration.picturePath, let data = try? Data(contentsOf: path) {
            streamPicture = UIImage(data: data)
        }

        initializeAudioSession()
        initializeRemoteCommandCenter()
        refreshNowPlayingData()

        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    }

    // MARK: - Public methods

    public func play() {
        player.play()
        updateNowPlayingProperties()
        delegates.invoke { $0.streamPlayerChangedState(self) }
    }

    public func pause() {
        player.pause()
        delegates.invoke { $0.streamPlayerChangedState(self) }
    }

    public func addDelegate(_ delegate: StreamPlayerDelegate) {
        delegates.add(delegate)
    }

    // MARK: - Overrides

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change _: [NSKeyValueChangeKey : Any]?, context _: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            var notifyDelegates = true

            switch keyPath {
            case "playbackBufferEmpty":
                isBuffering = true
            case "playbackLikelyToKeepUp":
                isBuffering = false
            case "playbackBufferFull":
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

    private func initializeAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback)
        try? audioSession.setMode(.spokenAudio)
    }

    private func initializeRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
    }

    private func refreshNowPlayingData() {
        apiClient.fetchNowPlaying { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let nowPlaying):
                let different = self.nowPlaying != nowPlaying
                self.nowPlaying = nowPlaying
                self.updateNowPlayingProperties()

                if different {
                    self.delegates.invoke { $0.streamPlayerChangedState(self) }
                }
            case .failure(let error):
                self.log.log(.error, "Failed to fetch Now Playing data: \(error)")
            }
        }
    }
}

// MARK: - tvOS specific

#if os(tvOS)

import AVKit

extension StreamPlayer {
    private func updateNowPlayingProperties() {
        var metadata = [AVMetadataItem]()

        let titleItem = makeMetadataItem(.commonIdentifierTitle, value: streamName)
        metadata.append(titleItem)

        let descItem = makeMetadataItem(.commonIdentifierDescription, value: episodeTitle)
        metadata.append(descItem)

        if let image = streamPicture, let data = image.pngData() {
            let artworkItem = makeMetadataItem(.commonIdentifierArtwork, value: data)
            metadata.append(artworkItem)
        }

        playerItem.externalMetadata = metadata
    }

    private func makeMetadataItem(_ identifier: AVMetadataIdentifier, value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
}
#else
#if os(iOS)

// MARK: - iOS specific

extension StreamPlayer {
    private func updateNowPlayingProperties() {
        var nowPlayingInfo: [String : Any] = [
            MPMediaItemPropertyArtist: streamName,
            MPMediaItemPropertyTitle: episodeTitle,
            MPNowPlayingInfoPropertyIsLiveStream: true,
        ]

        if let streamPicture = streamPicture {
            let bounds = streamPicture.size
            let artwork = MPMediaItemArtwork(boundsSize: bounds, requestHandler: { _ in streamPicture })
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

#else

extension StreamPlayer {
    private func updateNowPlayingProperties() {
        // Nothing to do for non-IOS & non-tvOS platforms.
    }
}

#endif
#endif
