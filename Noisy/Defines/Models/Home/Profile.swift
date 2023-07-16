//
//  File.swift
//  Noisy
//
//  Created by Davor Lakus on 13.06.2023..
//

import Foundation

struct Profile: Codable {
    struct ExternalUrls: Codable {
        let spotify: String
    }
    
    struct Followers: Codable {
        let total: Int
        let href: String?
    }
    
    let images: [SpotifyImage]
    let id: String
    let externalUrls: ExternalUrls
    let followers: Followers
    let href: String
    let displayName: String
    let type: String
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case images, id, followers, href
        case externalUrls = "external_urls" 
        case displayName = "display_name"
        case type, uri
    }
}
