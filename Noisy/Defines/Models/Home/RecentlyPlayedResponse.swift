//
//  RecentlyPlayedResponse.swift
//  Noisy
//
//  Created by Davor Lakus on 24.08.2023..
//

import Foundation

struct RecentlyPlayedResponse: Codable {
    let next: String?
    let cursors: Cursors?
    let items: [PlayHistoricObject]
}

struct Cursors: Codable {
    let after: String
    let before: String
}

struct PlayHistoricObject: Codable {
    let track: Track
    let playedAt: String
    
    enum CodingKeys: String, CodingKey {
        case track
        case playedAt = "played_at"
    }
}
