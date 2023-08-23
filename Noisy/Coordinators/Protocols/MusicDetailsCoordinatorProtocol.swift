//
//  MusicDetailsCoordinatorProtocol.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

protocol MusicDetailsCoordinatorProtocol: VerticalCoordinatorProtocol {
    
    var artistViewModelStack: Stack<ArtistViewModel> { get set }
    var albumViewModelStack: Stack<AlbumViewModel> { get set }
    var playlistViewModelStack: Stack<PlaylistViewModel> { get set }
    var playlistsViewModel: PlaylistsViewModel? { get set }
    
    var onDidTapPlayAllButton: PassthroughSubject<Void, Never> { get set }
    var onDidTapTrackRow: PassthroughSubject<Void, Never> { get set }
    var onDidTapDiscoverButton: PassthroughSubject<Artist, Never> {get set }
    var musicDetailsService: MusicDetailsService { get set }
    var queueManager: QueueManager { get set }
    var cancellables: Set<AnyCancellable> { get set }

    func bindArtistViewModel(for artist: Artist)
    func bindAlbumViewModel(for album: Album)
    func bindPlaylistViewModel(for tracks: Playlist)
    func bindPlaylistsViewModel(with tracks: [Track])
    
    func pushArtistViewModel(for artist: Artist)
    func pushAlbumViewModel(for album: Album)
    func pushPlaylistViewModel(for playlist: Playlist)
    func pushPlaylistsViewModel(with tracks: [Track])
}

extension MusicDetailsCoordinatorProtocol {
    func bindArtistViewModel(for artist: Artist) {
        let viewModel = ArtistViewModel(artist: artist, musicDetailsService: musicDetailsService, queueManager: queueManager)
        viewModel.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
                self?.artistViewModelStack.pop()
            }
            .store(in: &cancellables)
        
        viewModel.onDidTapSimilarArtistButton
            .sink { [weak self] artist in
                self?.pushArtistViewModel(for: artist)
            }
            .store(in: &cancellables)
        
        viewModel.onDidTapAlbumRow
            .sink {[weak self] album in
                self?.pushAlbumViewModel(for: album)
            }
            .store(in: &cancellables)
        
        viewModel.onDidTapTrackRow = onDidTapTrackRow
        
        viewModel.onDidTapDiscoverButton = onDidTapDiscoverButton
        
        artistViewModelStack.push(viewModel)
    }
    
    func bindAlbumViewModel(for album: Album) {
        let viewModel = AlbumViewModel(album: album, musicDetailsService: musicDetailsService, queueManager: queueManager)
        viewModel.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
                self?.albumViewModelStack.pop()
            }
            .store(in: &cancellables)
        
        viewModel.onDidTapPlayAllButton = onDidTapPlayAllButton
        viewModel.onDidTapTrackRow = onDidTapTrackRow
        
        viewModel.onDidTapArtistButton
            .sink {[weak self] artist in
                self?.pushArtistViewModel(for: artist)
            }
            .store(in: &cancellables)
        
        viewModel.onDidTapAlbumButton
            .sink {[weak self] album in
                self?.pushAlbumViewModel(for: album)
            }
            .store(in: &cancellables)
        
        albumViewModelStack.push(viewModel)
    }

    func bindPlaylistViewModel(for playlist: Playlist) {
        let viewModel = PlaylistViewModel(playlist: playlist, musicDetailsService: musicDetailsService, queueManager: queueManager)
        
        viewModel.onDidTapBackButton
            .sink { [weak self] in
                withAnimation {
                    self?.pop()
                    self?.playlistViewModelStack.pop()
                }
            }
            .store(in: &cancellables)
        
        viewModel.onDidTapPlayAllButton = onDidTapPlayAllButton
        viewModel.onDidTapTrackRow = onDidTapTrackRow
        
        viewModel.onDidTapArtistButton
            .sink {[weak self] artist in
                self?.pushArtistViewModel(for: artist)
            }
            .store(in: &cancellables)
        
        viewModel.onDidTapAlbumButton
            .sink {[weak self] album in
                self?.pushAlbumViewModel(for: album)
            }
            .store(in: &cancellables)
        
        playlistViewModelStack.push(viewModel)
    }
    
    func bindPlaylistsViewModel(with tracks: [Track]) {
        let viewModel = PlaylistsViewModel(tracks: tracks, musicDetailsService: musicDetailsService)
        
        viewModel.onDidTapBackButton
            .sink { [weak self] in
                withAnimation {
                    self?.pop()
                    self?.playlistsViewModel = nil
                }
            }
            .store(in: &cancellables)
        
        playlistsViewModel = viewModel
    }
    
    @ViewBuilder
    func presentArtistView() -> some View {
        if let artistViewModel = artistViewModelStack.peek() {
            ArtistView(viewModel: artistViewModel)
        }
    }
    
    @ViewBuilder
    func presentAlbumView() -> some View {
        if let albumViewModel = albumViewModelStack.peek() {
            AlbumView(viewModel: albumViewModel)
        }
    }
    
    @ViewBuilder
    func presentPlaylistView() -> some View {
        if let playlistViewModel = playlistViewModelStack.peek() {
            PlaylistView(viewModel: playlistViewModel)
        }
    }

    @ViewBuilder
    func presentPlaylistsView() -> some View {
        if let playlistsViewModel = playlistsViewModel {
            PlaylistsView(viewModel: playlistsViewModel)
        }
    }
}
