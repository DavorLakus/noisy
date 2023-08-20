//
//  AudioFeatures.swift
//  Noisy
//
//  Created by Davor Lakus on 15.08.2023..
//

import Foundation

struct AudioFeaturesResponse: Codable {
    let audioFeatures: [AudioFeatures]
    
    enum CodingKeys: String, CodingKey {
        case audioFeatures = "audio_features"
    }
}

struct AudioFeatures: Codable {
    let id: String
    let durationMS: Int
    let acousticness: Double
    let danceability: Double
    let energy: Double
    let instrumentalness: Double
    let key: Int
    let liveness: Double
    let loudness: Double
    let mode: Int
    let speechiness: Double
    let tempo: Double
    let timeSignature: Int
    let valence: Double
    
    enum CodingKeys: String, CodingKey {
        case timeSignature = "time_signature"
        case durationMS = "duration_ms"
        case id, acousticness, danceability, energy, instrumentalness, key, liveness, loudness, mode, speechiness, tempo, valence
    }
    
    var normalizedValues: [Double] {
        [acousticness, danceability, energy, instrumentalness, liveness, Double(key) / Seed.key.multiplier, loudness / -Seed.loudness.multiplier, Double(mode) / Seed.mode.multiplier, speechiness, tempo / Seed.tempo.multiplier, Double(timeSignature) / Seed.timeSignature.multiplier, valence]
    }
    
    var associatedSeeds: [Seed] {
        [
            .acousticness,
            .danceability,
            .energy,
            .instrumentalness,
            .key,
            .liveness,
            .loudness,
            .mode,
            .speechiness,
            .tempo,
            .timeSignature,
            .valence
        ]
    }
}
