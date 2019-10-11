import Foundation
import jrkKitWatch

/// 10/10 naming, boss
class ServerDataManager {
    var currentConfiguredServer: String? {
        get {
            return UserDefaults.standard.value(forKey: "serverState.url") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "serverState.url")
        }
    }
}

extension ServerDataManager: ServerStateDelegate {
    func phoneConnection(_ connection: PhoneConnection, shouldRequestDataForServerState serverState: ServerState) -> Bool {
        return serverState.rootUrl != currentConfiguredServer
    }
}
