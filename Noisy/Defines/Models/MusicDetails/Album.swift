//
//  Album.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import Foundation

struct AlbumsResponse {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [Album]
}

struct AlbumResponse: Codable, Hashable {
    let items: [Album]
}

struct Album: Codable, Hashable {
    let name: String
    let releaseDate: String
    let artists: [Artist]?
    let genres: [String]?
    let totalTracks: Int
    let popularity: Int?
    let images: [SpotifyImage]
    let href: String
    let items: Tracks?
    
    enum CodingKeys: String, CodingKey {
        case totalTracks = "total_tracks"
        case releaseDate = "release_date"
        case name, genres, popularity, href, images, items, artists
    }
}
