import Foundation

class TestData {
    static let successfulRootDocumentResponse =
    """
    {
        "streamName": "test stream",
        "streamPicture": "/picture.png",
        "playlist": "/playlist.m3u8"
    }
    """.data(using: .utf8)!
}
