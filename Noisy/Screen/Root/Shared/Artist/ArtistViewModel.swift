//
//  ArtistViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import Combine
import SwiftUI

final class ArtistViewModel: ObservableObject, Equatable {
    static func == (lhs: ArtistViewModel, rhs: ArtistViewModel) -> Bool {
        lhs.artist != rhs.artist
    }
    
    // MARK: - Published properties
    @Published var topTracks: [Track] = []
    @Published var albums: [Album] = []
    @Published var relatedArtists: [Artist] = []
    @Published var isMostPlayedExpanded = false
    @Published var isAlbumsExpanded = false
    @Published var isToastPresented = false
    @Published var isOptionsSheetPresented = false

    // MARK: - Coordinator actions
    var onDidTapTrackRow: PassthroughSubject<Track, Never>?
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    let onDidTapAlbumRow = PassthroughSubject<Album, Never>()
    let onDidTapSimilarArtistButton = PassthroughSubject<Artist, Never>()
    
    // MARK: - Public properties
    let artist: Artist
    var options: [OptionRow] = []
    var toastMessage: String = .empty
    
    // MARK: - Private properties
    private let musicDetailsService: MusicDetailsService
    private let queueManager: QueueManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(artist: Artist, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.artist = artist
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        fetchTopTracks()
        fetchAlbums()
        fetchRelatedArtists()
    }
}

// MARK: - Public extension
extension ArtistViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func trackRowTapped(for track: Track) {
        onDidTapTrackRow?.send(track)
    }
    
    func albumRowTapped(for album: Album) {
        onDidTapAlbumRow.send(album)
    }
    
    func artistButtonTapped(for artist: Artist) {
        onDidTapSimilarArtistButton.send(artist)
    }
    
    func artistOptionsTapped(for artist: Artist) {
        
    }
    
    func trackOptionsTapped(for track: Track) {
        options = [addTrackToQueueOption(track)]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
    
    func addTrackToQueueOption(_ track: Track) -> OptionRow {
        let addToQueueSubject = PassthroughSubject<Void, Never>()
        
        addToQueueSubject
            .sink { [weak self] in
                self?.queueManager.append(track)
                self?.toastMessage = "\(track.name) \(String.Shared.addedToQueue)"
                withAnimation {
                    self?.isToastPresented = true
                }
            }
            .store(in: &cancellables)
        
        return OptionRow.addToQueue(action: addToQueueSubject)
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
        musicDetailsService.getArtistsAlbums(for: artist.id)
            .sink { [weak self] albums in
                self?.albums = albums
            }
            .store(in: &cancellables)
    }
    
    func fetchRelatedArtists() {
        musicDetailsService.getArtistsRelatedArtists(for: artist.id)
            .sink { [weak self] artists in
                self?.relatedArtists = artists
            }
            .store(in: &cancellables)
    }
}
