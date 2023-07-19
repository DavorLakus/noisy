//
//  Playlists.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import Foundation

struct PlaylistsResponse: Codable, Hashable {
    let limit: Int
    let next: String?
    let previous: String?
    let offset: Int
    let total: Int
    let items: [Playlist]
}

struct Playlist: Codable, Hashable {
    let id: String
    let name: String
    let images: [SpotifyImage]?
    let owner: Owner
    let tracks: TracksInfo
}

struct TracksInfo: Codable, Hashable {
    let total: Int
}

struct Owner: Codable, Hashable {
    let id: String
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}
