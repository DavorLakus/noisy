//
//  PlaylistsViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import Combine
import SwiftUI

final class PlaylistsViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var playlists: [Playlist] = []
    @Published var selectedPlaylists: [Playlist] = []
    @Published var isCreateNewSheetPresented = false
    @Published var isToastPresented = false
    @Published var newPlaylistTitle: String = .empty
    
    // MARK: - Coordinator actions
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    var toastMessage: String = .empty
    
    // MARK: - Private properties
    private let tracks: [Track]
    private var total: Int = .zero
    private var limit: Int = 20
    private var offset: Int = .zero
    private let musicDetailsService: MusicDetailsService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(tracks: [Track], musicDetailsService: MusicDetailsService) {
        self.tracks = tracks
        self.musicDetailsService = musicDetailsService
    }
}

// MARK: - Public extension
extension PlaylistsViewModel {
    func viewDidAppear() {
        getPlaylistsCount()
    }
    
    func doneButtonTapped() {
        if selectedPlaylists.isEmpty {
            onDidTapBackButton.send()
        } else {
            var count = 0
            let tracks = tracks.map(\.uri).joined(separator: ",")

            selectedPlaylists.forEach { playlist in
                musicDetailsService.addTracksToPlaylist(playlist.id, tracks: tracks)
                    .sink { [weak self] in
                        count += 1
                        guard let self else { return }
                        if count == self.selectedPlaylists.count {
                            self.toastMessage = String.Shared.addedToPlaylist
                            withAnimation {
                                self.isToastPresented = true
                            }
                            Just(self.onDidTapBackButton)
                                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                                .sink {
                                    $0.send()
                                }
                                .store(in: &self.cancellables)
                        }
                    }
                    .store(in: &cancellables)
                
            }
        }
    }
    
    func createNewSheetToggle() {
        withAnimation {
            isCreateNewSheetPresented.toggle()
        }
    }
    
    func savePlaylistTapped() {
        let tracks = tracks.map(\.uri).joined(separator: ",")

        musicDetailsService.createNewPlaylist(newPlaylistTitle)
            .flatMap { [weak self] newPlaylist in
                guard let self else { return PassthroughSubject<Void, Never>()}
                return musicDetailsService.addTracksToPlaylist(newPlaylist.id, tracks: tracks)
            }
            .flatMap { [weak self] in
                self?.toastMessage = String.Shared.addedToPlaylist
                withAnimation {
                    self?.isToastPresented = true
                }
                self?.createNewSheetToggle()
                return Just(self?.onDidTapBackButton)
            }
            .delay(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .sink {
                $0?.send()
            }
            .store(in: &cancellables)
    }
    
    func playlistRowTapped(for playlist: Playlist) {
        withAnimation {
            if selectedPlaylists.contains(playlist) {
                selectedPlaylists = selectedPlaylists.filter { $0.id != playlist.id }
            } else {
                selectedPlaylists.append(playlist)
            }
        }
    }
}

// MARK: - Private extension
private extension PlaylistsViewModel {
    func getPlaylistsCount() {
        musicDetailsService.getPlaylists(limit: 1, offset: 0)
            .sink { [weak self] response in
                guard let self else { return }
                self.total = response.total
                self.limit = min(20, response.total)
                self.fetchPlaylists()
            }
            .store(in: &cancellables)
    }
    
    func fetchPlaylists() {
        musicDetailsService.getPlaylists(limit: limit, offset: offset)
            .sink { [weak self] response in
                guard let self else { return }
                withAnimation {
                    self.playlists += response.items
                }
                if response.total > self.offset {
                    self.offset += self.limit
                    self.limit = min(20, response.total - self.offset)
                    self.fetchPlaylists()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Equatable
extension PlaylistsViewModel: Equatable {
    static func == (lhs: PlaylistsViewModel, rhs: PlaylistsViewModel) -> Bool {
        lhs.playlists != rhs.playlists
    }
}
