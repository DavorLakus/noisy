//
//  Artist.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import Foundation

struct RelatedArtistsResponse: Codable, Hashable {
    let artists: [Artist]
}

struct Artist: Codable, Hashable {
    let id: String
    let name: String
    let href: String
    let images: [SpotifyImage]?
}

struct ArtistsResponse: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [Artist]
}
