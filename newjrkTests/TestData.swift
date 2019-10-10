import Foundation

class TestData {
    static let rootDocumentResponse =
    """
    {
        "streamName": "test stream",
        "streamPicture": "/picture.png",
        "playlist": "/playlist.m3u8",
        "nowPlaying": "/live/nowPlaying",
        "eventLog": "/logs/events",
        "episodeLog": "/logs/episodes"
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

    static let episodeLogResponse =
    """
    [
        {
            "description" : "2012",
            "title" : "Torsdag 16/2",
            "timestamp" : "2019-10-10T17:47:57.049Z"
        },
        {
            "description" : "2013",
            "title" : "Torsdag 19/2",
            "timestamp" : "2019-10-10T14:47:57.049Z"
        },
    ]
    """.data(using: .utf8)!

    static let eventLogResponse =
    """
    [
        {
            "description" : null,
            "timestamp" : "2019-10-10T17:44:24.512Z",
            "title" : "Server started"
        },
        {
            "title" : "Download started",
            "description" : "S3-key '20120216.mp3'",
            "timestamp" : "2019-10-10T17:44:25.757Z"
        },
        {
            "title" : "Segmentation started",
            "timestamp" : "2019-10-10T17:44:27.116Z",
            "description" : "S3-key '20120216.mp3'"
        },
    ]
    """.data(using: .utf8)!
}
