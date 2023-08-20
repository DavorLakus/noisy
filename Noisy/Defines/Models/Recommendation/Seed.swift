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
    
    var description: String {
        switch self {
        case .acousticness:
            return "A confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic."
        case .danceability:
            return "Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable."
        case .duration:
            return "The duration of the track in milliseconds."
        case .energy:
            return "Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy."
        case .instrumentalness:
            return "Predicts whether a track contains no vocals. 'Ooh' and 'aah' sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly 'vocal'. The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0."
        case .key:
            return "The key the track is in. Integers map to pitches using standard Pitch Class notation. E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on. If no key was detected, the value is -1.\n\nExample value: 9\nRange: -1 - 11"
        case .liveness:
            return "Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live.\nExample value: 0.0866"
        case .loudness:
            return "The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typically range between -60 and 0 db."
        case .mode:
            return "Mode indicates the modality (major or minor) of a track, the type of scale from which its melodic content is derived. Major is represented by 1 and minor is 0."
        case .popularity:
            return "The popularity of the track. The value will be between 0 and 100, with 100 being the most popular. The popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are."
        case .speechiness:
            return "Speechiness detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g. talk show, audio book, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks."
        case .tempo:
            return "The overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration."
        case .timeSignature:
            return "An estimated time signature. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure). The time signature ranges from 3 to 7 indicating time signatures of '3/4, to '7/4'."
        case .valence:
            return "A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry)."
        }
    }
    
    static func musicKeyFromValue(_ value: Double) -> String {
        precondition((-1.0...11.0).contains(value))
        
        switch Int(value) {
        case 0:
            return "C"
        case 1:
            return "C♯/D♭"
        case 2:
            return "D"
        case 3:
            return "D♯/E♭"
        case 4:
            return "E"
        case 5:
            return "F"
        case 6:
            return "F♯/G♭"
        case 7:
            return "G"
        case 8:
            return "G♯/A♭"
        case 9:
            return "A"
        case 10:
            return "A♯/B"
        case 11:
            return "H"
        default:
            return "N/A"
        }
    }
    
    static func modeFromValue(_ value: Double) -> String {
        precondition((0.0...1.0).contains(value))

        switch Int(value) {
        case 0:
            return "minor"
        case 1:
            return "major"
        default:
            return "N/A"
        }
    }
}
