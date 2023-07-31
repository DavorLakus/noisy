//
//  QueueState.swift
//  Noisy
//
//  Created by Davor Lakus on 20.07.2023..
//

import Foundation

final class QueueState: Codable {
    var tracks: [Track]
    var currentTrack: Track?
    var currentTrackIndex: Int
    var currentTime: TimeInterval
    
    init(tracks: [Track], currentTrackIndex: Int = 0) {
        self.tracks = tracks
        if !tracks.isEmpty {
            self.currentTrack = tracks[currentTrackIndex]
        }
        self.currentTrackIndex = currentTrackIndex
        currentTime = .zero
    }
    
    func next() -> Track? {
        currentTime = 0
        
        if currentTrackIndex < tracks.count - 1 {
            currentTrackIndex += 1
            currentTrack = tracks[currentTrackIndex]
            return currentTrack
        }
        currentTrackIndex = 0
        currentTrack = tracks[currentTrackIndex]
        return currentTrack
    }
    
    func previous() -> Track? {
        currentTime = 0
        
        if currentTrackIndex > 0 {
            currentTrackIndex -= 1
            currentTrack = tracks[currentTrackIndex]
            return currentTrack
        }
        currentTrackIndex = tracks.count - 1
        currentTrack = tracks[currentTrackIndex]
        return currentTrack
    }
}
