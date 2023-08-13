//
//  Track.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import Foundation

struct Tracks: Codable, Hashable {
    let tracks: [Track]
}

struct Track: Codable, Hashable {
    let id: String
    let name: String
    let album: Album?
    let artists: [Artist]
    let durationMs: Int?
    let popularity: Int?
    let previewUrl: String?
    let href: String
    
    enum CodingKeys: String, CodingKey {
        case durationMs = "duration_ms"
        case previewUrl = "preview_url"
        case id, name, album, artists, popularity, href
    }
}

struct TracksResponse: Codable, Hashable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [Track]
}

struct TrackObjectsResponse: Codable, Hashable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [TrackObject]
}

struct TrackObject: Codable, Hashable {
    let track: Track
}
