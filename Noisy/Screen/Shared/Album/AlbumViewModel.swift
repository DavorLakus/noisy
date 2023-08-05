//
//  AlbumViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import Combine
import SwiftUI

final class AlbumViewModel: ObservableObject, Equatable {
    static func == (lhs: AlbumViewModel, rhs: AlbumViewModel) -> Bool {
        lhs.album != rhs.album
    }
    
    // MARK: - Published properties
    @Published var tracks: [Track] = []
    @Published var relatedAlbums: [Album] = []
    @Published var relatedArtists: [Artist] = []
    @Published var isToastPresented = false
    @Published var isOptionsSheetPresented = false
    
    // MARK: - Coordinator actions
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    var onDidTapTrackRow = PassthroughSubject<Track, Never>()
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumButton = PassthroughSubject<Album, Never>()
    var onDidTapPlayAllButton = PassthroughSubject<[Track], Never>()
    
    // MARK: - Public properties
    let album: Album
    var options: [OptionRow] = []
    var toastMessage: String = .empty
    
    // MARK: - Private properties
    private var offset: Int = .zero
    private let limit = 50
    private let musicDetailsService: MusicDetailsService
    private let queueManager: QueueManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(album: Album, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.album = album
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        fetchTracks()
    }
}

// MARK: - Public extension
extension AlbumViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func albumOptionsTapped() {
        let addToQueueSubject = PassthroughSubject<Void, Never>()
        
        addToQueueSubject
            .sink { [weak self] in
                guard let self else { return }
                self.queueManager.append(self.tracks)
                self.toastMessage = "\(String.Shared.album) \(String.Shared.addedToQueue)"
                withAnimation {
                    self.isToastPresented = true
                }
            }
            .store(in: &cancellables)
        
        let addToQueueOption = OptionRow.addToQueue(action: addToQueueSubject)
        options = [addToQueueOption]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
    
    func playAllButtonTapped() {
        onDidTapPlayAllButton.send(tracks)
    }
    
    func trackRowTapped(for track: Track) {
        onDidTapTrackRow.send(track)
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
        
        let addToQueueOption = OptionRow.addToQueue(action: addToQueueSubject)
        options = [addToQueueOption]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
}

// MARK: - Private extension
private extension AlbumViewModel {
    func fetchTracks() {
        musicDetailsService.getAlbumTracks(for: album.id, limit: limit, offset: offset)
            .sink { [weak self] result in
                guard let self else { return }
                if result.limit > self.offset + self.limit {
                    self.offset += self.limit
                    self.fetchTracks()
                }
                self.tracks += result.items
            }
            .store(in: &cancellables)
    }
}
