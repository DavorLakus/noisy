//
//  Scopes.swift
//  Noisy
//
//  Created by Davor Lakus on 16.07.2023..
//

import Foundation

enum Scope: String, CaseIterable {
    case readPlaybackState = "user-read-playback-state"
    case modifyPlaybackState = "user-modify-playback-state"
    case readCurrentlyPlaying = "user-read-currently-playing"
    case playlistReadPrivate = "playlist-read-private"
    case playlistReadCollaborative = "playlist-read-collaborative"
    case playlistModifyPrivate = "playlist-modify-private"
    case playlistModifyPublic = "playlist-modify-public"
    case userReadPlaybackPosition = "user-read-playback-position"
    case userTopRead = "user-top-read"
    case userReadRecentlyPlayed = "user-read-recently-played"
    case userLibraryRead = "user-library-read"
    case userLibraryModify = "user-library-modify"
}
