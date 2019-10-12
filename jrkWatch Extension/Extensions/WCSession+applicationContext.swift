import Foundation
import WatchConnectivity
import jrkKitWatch

extension WCSession {
    var context: ApplicationContext? {
        return ApplicationContext(fromDictionary: receivedApplicationContext)
    }
}
