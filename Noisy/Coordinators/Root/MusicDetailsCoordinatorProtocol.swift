//
//  MusicDetailsCoordinatorProtocol.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

protocol MusicDetailsCoordinatorProtocol: VerticalCoordinatorProtocol {
    
    var artistViewModel: ArtistViewModel? { get set }
    var albumViewModel: AlbumViewModel? { get set }
    var playlistViewModel: PlaylistViewModel? { get set }
    var playlistsViewModel: PlaylistsViewModel? { get set }
    var musicDetailsService: MusicDetailsService { get set }
    var cancellables: Set<AnyCancellable> { get set }

    func bindArtistViewModel(for artist: Artist)
    func bindAlbumViewModel(for album: Album)
    func bindPlaylistViewModel(for tracks: Playlist)
    func bindPlaylistsViewModel(for playlists: [Album])
}

extension MusicDetailsCoordinatorProtocol {
    func bindArtistViewModel(for artist: Artist) {
        artistViewModel = ArtistViewModel(artist: artist, musicDetailsService: musicDetailsService)
        artistViewModel?.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
            }
            .store(in: &cancellables)
    }
    
    func bindAlbumViewModel(for album: Album) {
        albumViewModel = AlbumViewModel(album: album, musicDetailsService: musicDetailsService)
        albumViewModel?.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
            }
            .store(in: &cancellables)
    }

    func bindPlaylistViewModel(for playlist: Playlist) {
        playlistViewModel = PlaylistViewModel(playlist: playlist, musicDetailsService: musicDetailsService)
        
        playlistViewModel?.onDidTapBackButton
            .sink { [weak self] in
                withAnimation {
                    self?.pop()
                }
            }
            .store(in: &cancellables)
    }
    
    func bindPlaylistsViewModel(for playlists: [Album]) {
        playlistsViewModel = PlaylistsViewModel(playlists: playlists, musicDetailsService: musicDetailsService)
        
        playlistsViewModel?.onDidTapBackButton
            .sink { [weak self] in
                withAnimation {
                    self?.pop()
                }
            }
            .store(in: &cancellables)
    }
    
    @ViewBuilder
    func presentArtistView() -> some View {
        if let artistViewModel {
            ArtistView(viewModel: artistViewModel)
        }
    }
    
    @ViewBuilder
    func presentAlbumView() -> some View {
        if let albumViewModel {
            AlbumView(viewModel: albumViewModel)
        }
    }
    
    @ViewBuilder
    func presentPlaylistView() -> some View {
        if let playlistViewModel {
            PlaylistView(viewModel: playlistViewModel)
        }
    }

    @ViewBuilder
    func presentPlaylistsView() -> some View {
        if let playlistsViewModel {
            PlaylistsView(viewModel: playlistsViewModel)
        }
    }
}