//
//  Image.swift
//  Noisy
//
//  Created by Davor Lakus on 16.07.2023..
//

import Foundation

struct SpotifyImage: Codable, Equatable, Hashable {
    let url: String
    let width: Int?
    let height: Int?
}
