import Foundation

enum LogLevel: String {
    case debug = "DBG"
    case warn  = "WRN"
    case error = "ERR"
}

struct Log {
    private let owner: AnyObject

    init(for owner: AnyObject) {
        self.owner = owner
    }

    func log(_ level: LogLevel, _ message: String) {
        let className = String(describing: type(of: owner))
        print("[JRKLOG][\(level.rawValue)][\(className)] \(message)")
    }

    func log(_ message: String) {
        log(.debug, message)
    }
}
