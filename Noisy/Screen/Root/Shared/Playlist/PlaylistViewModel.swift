//
//  PlaylistViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import Combine
import SwiftUI

final class PlaylistViewModel: ObservableObject, Equatable {
    static func == (lhs: PlaylistViewModel, rhs: PlaylistViewModel) -> Bool {
        lhs.playlist != rhs.playlist
    }
    
    // MARK: - Published properties
    @Published var tracks: [Track] = []
    @Published var relatedAlbums: [Album] = []
    @Published var relatedArtists: [Artist] = []
    @Published var isToastPresented = false
    @Published var isOptionsSheetPresented = false
    
    // MARK: - Coordinator actions
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    let onDidTapTrackRow = PassthroughSubject<Void, Never>()
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumButton = PassthroughSubject<Album, Never>()
    let onDidTapPlayAllButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    let playlist: Playlist
    var options: [Option] = []
    var toastMessage: String = .empty
    
    // MARK: - Private properties
    private var offset: Int = .zero
    private let limit = 50
    private let musicDetailsService: MusicDetailsService
    private let queueManager: QueueManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(playlist: Playlist, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.playlist = playlist
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        fetchTracks()
    }
}

// MARK: - Public extension
extension PlaylistViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func playlistOptionsTapped() {
        let addToQueueSubject = PassthroughSubject<Void, Never>()
        
        addToQueueSubject
            .sink { [weak self] in
                guard let self else { return }
                self.queueManager.append(tracks)
                self.toastMessage = "\(String.Shared.playlist) \(String.Shared.addedToQueue)"
                withAnimation {
                    self.isToastPresented = true
                }
            }
            .store(in: &cancellables)
        
        let addToQueueOption = Option.addToQueue(action: addToQueueSubject)
        options = [addToQueueOption]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
    
    func playAllButtonTapped() {
        queueManager.setState(with: tracks)
        onDidTapPlayAllButton.send()
    }
    
    func trackRowTapped(for track: Track) {
        queueManager.setState(with: tracks, currentTrackIndex: tracks.firstIndex(of: track))
        onDidTapTrackRow.send()
    }
    
    func artistButtonTapped(for artist: Artist) {
        onDidTapArtistButton.send(artist)
    }
    
    func trackOptionsTapped(for track: Track) {
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
        
        let addToQueueOption = Option.addToQueue(action: addToQueueSubject)
        options = [addToQueueOption]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
}

// MARK: - Private extension
private extension PlaylistViewModel {
    func fetchTracks() {
        musicDetailsService.getPlaylistTracks(for: playlist.id, limit: limit, offset: offset)
            .sink { [weak self] result in
                guard let self else { return }
                if result.limit > self.offset + self.limit {
                    self.offset += self.limit
                    self.fetchTracks()
                }
                self.tracks += result.items.map(\.track)
            }
            .store(in: &cancellables)
    }
}
