//
//  Playlist.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import Foundation

struct PlaylistResponse: Codable, Hashable {
    let id: String
    let name: String
    let images: [SpotifyImage]?
    let owner: Owner
    let items: [TracksResponse]
}
