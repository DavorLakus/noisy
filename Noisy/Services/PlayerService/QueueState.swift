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
        persist()
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
        persist()
        return currentTrack
    }
    
    func append(_ track: Track, playNext: Bool) {
        if playNext {
            tracks.insert(track, at: currentTrackIndex + 1)
        } else {
            tracks.append(track)
        }
        persist()
    }
    
    func append(_ tracks: [Track], playNext: Bool) {
        if playNext {
            self.tracks.insert(contentsOf: tracks, at: currentTrackIndex + 1)
        } else {
            self.tracks += tracks
        }
        persist()
    }
    
    func remove(_ track: EnumeratedSequence<[Track]>.Element) -> Bool {
        if tracks.count > 1 {
            tracks.remove(at: track.offset)
            if track.offset == currentTrackIndex {
                currentTrackIndex =  currentTrackIndex > 0 ? currentTrackIndex - 1 : 0
                currentTrack = tracks[currentTrackIndex]
                currentTime = .zero
                persist()
                return true
            }
        }
        persist()
        return false
    }
    
    func clearAll() {
        var removalOffsets = IndexSet()
        tracks.enumerated().forEach { enumeratedTrack in
            if enumeratedTrack.element != currentTrack,
               enumeratedTrack.offset != currentTrackIndex {
                removalOffsets.insert(enumeratedTrack.offset)
            }
        }
        tracks.remove(atOffsets: removalOffsets)
        persist()
    }
    
    func persist() {
        if let stateData = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(stateData, forKey: .UserDefaults.queueState)
        }
    }
}
