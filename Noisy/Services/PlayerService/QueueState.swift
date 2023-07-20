//
//  QueueState.swift
//  Noisy
//
//  Created by Davor Lakus on 20.07.2023..
//

import Foundation

final class QueueState: Codable {
    var tracks: [Track]
    var currentTrack: Track
    var currentTrackIndex: Int
    var currentTime: TimeInterval
    
    init(tracks: [Track], currentTrackIndex: Int = 0) {
        self.tracks = tracks
        self.currentTrack = tracks[currentTrackIndex]
        self.currentTrackIndex = currentTrackIndex
        currentTime = .zero
    }
    
    func next() -> Track {
        if currentTrackIndex < tracks.count - 1 {
            currentTrackIndex += 1
            return tracks[currentTrackIndex]
        }
        currentTrackIndex = 0
        return tracks[currentTrackIndex]
    }
    
    func previous() -> Track {
        if currentTrackIndex > 0 {
            currentTrackIndex -= 1
            return tracks[currentTrackIndex]
        }
        currentTrackIndex -= 1
        return tracks[currentTrackIndex]
    }
}
