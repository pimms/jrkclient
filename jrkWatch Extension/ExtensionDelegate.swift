import WatchKit
import WatchConnectivity
import jrkKitWatch

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    static var shared: ExtensionDelegate { WKExtension.shared().delegate as! ExtensionDelegate }

    let streamPictureStore = StreamPictureStore()

    private let session = WCSession.default
    private let messageReceiver: MessageReceiver
    private let streamPictureFetcher: StreamPictureFetcher

    private lazy var log = Log(for: self)

    override init() {
        messageReceiver = MessageReceiver(session: session)
        streamPictureFetcher = StreamPictureFetcher(session: session)
        super.init()

        messageReceiver.delegate = self
    }

    func applicationDidFinishLaunching() {
        
    }

    func applicationDidBecomeActive() {
        session.activate()
        refreshPictureIfNeeded()
    }

    func applicationWillResignActive() {

    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}

extension ExtensionDelegate {
    private func refreshPictureIfNeeded() {
        guard
            let context = session.context,
            shouldFetchPicture(forContext: context)
        else {
            return
        }

        streamPictureFetcher.fetchImage(forContext: context, completion: { [weak streamPictureStore] result in
            if case .success(let image) = result {
                streamPictureStore?.saveImage(image, forContext: context)
            }
        })
    }

    private func shouldFetchPicture(forContext context: ApplicationContext) -> Bool {
        return context.url != streamPictureStore.urlForCurrentImage
    }
}

// MARK: - MessageReceiverDelegate

extension ExtensionDelegate: MessageReceiverDelegate {
    func messageReceiver(_ messageReceiver: MessageReceiver, didReceiveNowPlayingState nowPlaying: NowPlayingState) {
        // TODO!
    }

    func messageReceiverDidReceiveApplicationContext(_ messageReceiver: MessageReceiver) {
        log.log("Received Application Context")
        refreshPictureIfNeeded()
    }
}
