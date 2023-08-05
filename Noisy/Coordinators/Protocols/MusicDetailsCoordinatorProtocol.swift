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
    var playlistsViewModelStack: Stack<PlaylistsViewModel> { get set }
    
    var onDidTapPlayAllButton: PassthroughSubject<[Track], Never> { get set }
    var onDidTapPlayerButton: PassthroughSubject<Track, Never> { get set }
    var musicDetailsService: MusicDetailsService { get set }
    var queueManager: QueueManager { get set }
    var cancellables: Set<AnyCancellable> { get set }

    func bindArtistViewModel(for artist: Artist)
    func bindAlbumViewModel(for album: Album)
    func bindPlaylistViewModel(for tracks: Playlist)
    func bindPlaylistsViewModel(for playlists: [Playlist])
    
    func pushArtistViewModel(for artist: Artist)
    func pushAlbumViewModel(for album: Album)
    func pushPlaylistViewModel(for playlist: Playlist)
    func pushPlaylistsViewModel(for playlists: [Playlist])
}

extension MusicDetailsCoordinatorProtocol {
    func bindArtistViewModel(for artist: Artist) {
        let viewModel = ArtistViewModel(artist: artist, musicDetailsService: musicDetailsService)
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
        
        viewModel.onDidTapTrackRow = onDidTapPlayerButton
        
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
        viewModel.onDidTapTrackRow = onDidTapPlayerButton
        
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
        viewModel.onDidTapTrackRow = onDidTapPlayerButton
        
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
    
    func bindPlaylistsViewModel(for playlists: [Playlist]) {
        let viewModel = PlaylistsViewModel(playlists: playlists, musicDetailsService: musicDetailsService)
        
        viewModel.onDidTapBackButton
            .sink { [weak self] in
                withAnimation {
                    self?.pop()
                    self?.playlistsViewModelStack.pop()
                }
            }
            .store(in: &cancellables)
        
        playlistsViewModelStack.push(viewModel)
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
        if let playlistsViewModel = playlistsViewModelStack.peek() {
            PlaylistsView(viewModel: playlistsViewModel)
        }
    }
}
