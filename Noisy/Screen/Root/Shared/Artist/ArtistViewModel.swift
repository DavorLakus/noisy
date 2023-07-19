//
//  ArtistViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import Combine
import SwiftUI

final class ArtistViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var topTracks: [Track] = []
    @Published var albums: [Album] = []
    @Published var relatedArtists: [Artist] = []
    @Published var isMostPlayedExpanded = false
    
    // MARK: - Coordinator actions
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    let onDidTapTrackRow = PassthroughSubject<Track, Never>()
    let onDidTapAlbumRow = PassthroughSubject<Album, Never>()
    let onDidTapSimilarArtistButton = PassthroughSubject<Artist, Never>()
    
    // MARK: - Public properties
    let artist: Artist
    
    // MARK: - Private properties
    private let musicDetailsService: MusicDetailsService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(artist: Artist, musicDetailsService: MusicDetailsService) {
        self.artist = artist
        self.musicDetailsService = musicDetailsService
        
        fetchTopTracks()
    }
}

// MARK: - Public extension
extension ArtistViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func trackRowTapped(for track: Track) {
        onDidTapTrackRow.send(track)
    }
    
    func albumRowTapped(for album: Album) {
        onDidTapAlbumRow.send(album)
    }
    
    func artistButtonTapped(for artist: Artist) {
        onDidTapSimilarArtistButton.send(artist)
    }
}

// MARK: - Private extension
private extension ArtistViewModel {
    func fetchTopTracks() {
        musicDetailsService.getArtistsTopTracks(for: artist.id)
            .sink { [weak self] tracks in
                self?.topTracks = tracks
            }
            .store(in: &cancellables)
    }
    
    func fetchAlbums() {
        
    }
    
    func fetchRelatedArtists() {
        
    }
}
