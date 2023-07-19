//
//  PlaylistViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import Combine
import SwiftUI

final class PlaylistViewModel: ObservableObject {
    // MARK: - Published properties
    
    // MARK: - Public properties
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    let onDidTapTrackRow = PassthroughSubject<Track, Never>()
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    
    // MARK: - Private properties
    private let playlist: Playlist
    private let musicDetailsService: MusicDetailsService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(playlist: Playlist,  musicDetailsService: MusicDetailsService) {
        self.playlist = playlist
        self.musicDetailsService = musicDetailsService
    }
}

// MARK: - Public extension
extension PlaylistViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func trackRowTapped(for track: Track) {
        onDidTapTrackRow.send(track)
    }
    
    func artistButtonTapped(for artist: Artist) {
        onDidTapArtistButton.send(artist)
    }
}

// MARK: - Private extension
private extension PlaylistViewModel {
    
}
