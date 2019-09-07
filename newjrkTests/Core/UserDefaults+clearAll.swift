import Foundation

extension UserDefaults {
    func clearAll() {
        if let domain = Bundle.main.bundleIdentifier {
            removePersistentDomain(forName: domain)
            synchronize()
        }
    }
}
