import Foundation

extension ServerConfiguration {
    var picturePath: URL? {
        let fileMgr = FileManager.default

        guard let hash = url?.absoluteString.stableHash else { return nil }
        guard let docDir = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileName = "pic_\(hash).png"
        return docDir.appendingPathComponent(fileName, isDirectory: false)
    }
}
