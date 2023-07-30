//
//  Seed.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import Foundation

enum Seed: CaseIterable, Hashable, Identifiable {
    case acousticness
    case danceability
    case duration
    case energy
    case instrumentalness
    case key
    case liveness
    case loudness
    case mode
    case popularity
    case speechiness
    case tempo
    case timeSignature
    case valence
    
    var id: Int {
        return Self.allCases.firstIndex(of: self) ?? .zero
    }
    
    var name: String {
        switch self {
        case .acousticness:
            return "Acousticness"
        case .danceability:
            return "Danceability"
        case .duration:
            return "Duration"
        case .energy:
            return "Energy"
        case .instrumentalness:
            return "Instrumentalness"
        case .key:
            return "Key"
        case .liveness:
            return  "Liveness"
        case .loudness:
            return  "Loudness"
        case .mode:
            return  "Mode"
        case .popularity:
            return "Popularity"
        case .speechiness:
            return "Speechiness"
        case .tempo:
            return  "Tempo (BPM)"
        case .timeSignature:
            return  "Time signature"
        case .valence:
            return  "Valence"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .acousticness, .danceability, .energy, .instrumentalness, .liveness, .mode, .speechiness, .valence:
            return  1.0
        case .loudness:
            return 60.0
        case .duration:
            return 1000.0
        case .key:
            return 11.0
        case .popularity:
            return 100.0
        case .tempo:
            return  200.0
        case .timeSignature:
            return  11.0
        }
    }
    
    func valueToString(value: Double) -> String {
        switch self {
        case .acousticness, .danceability, .energy, .instrumentalness, .liveness, .speechiness, .valence:
            return String(value)
        case .mode:
            return String(Int(value.rounded()))
        case .loudness:
            return String(Int(value * -60.0))
        case .duration:
            return String(Int(value * 1000.0 * 1000.0))
        case .key:
            return String(Int(value * 11.0))
        case .popularity:
            return String(Int(value * 100.0))
        case .tempo:
            return  String(Int(value * 200.0))
        case .timeSignature:
            return  String(Int(value * 11.0))
        }
    }
    
    var isInt: Bool {
        switch self {
        case .acousticness, .danceability, .energy, .instrumentalness, .liveness, .loudness, .mode, .speechiness, .valence:
            return  false
        case .duration, .key, .popularity, .tempo, .timeSignature:
            return  true
        }
    }
    
    var minCodingKey: String {
        switch self {
        case .duration:
            return "min_duration_ms"
        case .timeSignature:
            return "min_time_signature"
        case .loudness:
            return "max_loudness"
        default:
            return "min_\(String(describing: self))"
        }
    }
    
    var maxCodingKey: String {
        switch self {
        case .duration:
            return "max_duration_ms"
        case .timeSignature:
            return "max_time_signature"
        case .loudness:
            return "min_loudness"
        default:
            return "max_\(String(describing: self))"
        }
    }
    
    var targetCodingKey: String {
        switch self {
        case .duration:
            return "target_duration_ms"
        case .timeSignature:
            return "target_time_signature"
        default:
            return "target_\(String(describing: self))"
        }
    }
}
