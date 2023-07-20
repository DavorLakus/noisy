//
//  Recommendation.swift
//  Noisy
//
//  Created by Davor Lakus on 20.07.2023..
//

import Foundation

struct RecommendationResult: Codable {
    let seeds: RecommendationSeeds
    let tracks: [Track]
}

struct RecommendationSeeds: Codable {
    let afterFilteringSize: Int
    let afterRelinkingSize: Int
    let href: String
    let id: String
    let initialPoolSize: Int
    let type: String
}
