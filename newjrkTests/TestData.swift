import Foundation

class TestData {
    static let rootDocumentResponse =
    """
    {
        "streamName": "test stream",
        "streamPicture": "/picture.png",
        "playlist": "/playlist.m3u8",
        "nowPlaying": "/live/nowPlaying"
    }
    """.data(using: .utf8)!

    static let nowPlayingResponse =
    """
    {
       "season" : "2016",
       "name" : "Mandag 19/12",
       "playing" : true,
       "key" : "20161219.mp3"
    }
    """.data(using: .utf8)!
}
