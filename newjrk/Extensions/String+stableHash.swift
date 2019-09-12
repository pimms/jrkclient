import Foundation

extension String {
    // Thanks to:
    // https://stackoverflow.com/a/43149500
    var stableHash: String {
       var result = UInt64 (5381)
       let buf = [UInt8](utf8)
       for b in buf {
           result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
       }
       return "\(result)"
    }
}
