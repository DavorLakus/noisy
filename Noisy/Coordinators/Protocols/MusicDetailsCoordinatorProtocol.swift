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
    var miniPlayerViewModel: MiniPlayerViewModel? { get set }
    var profileViewModel: ProfileViewModel? { get set }
    var playerCoordinator: PlayerCoordinator? { get set }
    
    var isPlayerCoordinatorViewPresented: Bool { get set }
    var isProfileSheetPresented: Bool { get set }
    var isMiniPlayerPresented: Bool { get set }
    var onDidTapDiscoverButton: PassthroughSubject<Artist, Never> { get set }
    var onDidTapSignOut: PassthroughSubject<Void, Never> { get set }
    var musicDetailsService: MusicDetailsService { get set }
    var playerService: PlayerService { get set }
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

    func bindMiniPlayerViewModel(with queueManager: QueueManager)
    func bindProfileViewModel()
    func bindPlayerCoordinator()
    func getQueueManager() 
    func persistQueueManagerState()
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
        
        viewModel.onDidTapTrackRow
            .sink { [weak self] in
                self?.bindPlayerCoordinator()
            }
            .store(in: &cancellables)
        
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
        
        viewModel.onDidTapPlayAllButton
            .sink { [weak self] in
                self?.bindPlayerCoordinator()
            }
            .store(in: &cancellables)
        
        viewModel.onDidTapTrackRow
            .sink { [weak self] in
                self?.bindPlayerCoordinator()
            }
            .store(in: &cancellables)
        
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
        
        viewModel.onDidTapPlayAllButton
            .sink { [weak self] in
                self?.bindPlayerCoordinator()
            }
            .store(in: &cancellables)
        viewModel.onDidTapTrackRow
            .sink { [weak self] in
                self?.bindPlayerCoordinator()
            }
            .store(in: &cancellables)
        
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
    
    func bindMiniPlayerViewModel(with queueManager: QueueManager) {
        miniPlayerViewModel = MiniPlayerViewModel(queueManager: queueManager)
        
        miniPlayerViewModel?.onDidTapMiniPlayer
            .sink { [weak self] in
                self?.bindPlayerCoordinator()
            }
            .store(in: &cancellables)
        
        withAnimation {
            isMiniPlayerPresented = true
        }
    }
    
    @ViewBuilder
    func presentMiniPlayer() -> some View {
        if let miniPlayerViewModel {
            MiniPlayerView(viewModel: miniPlayerViewModel)
        }
    }
    
    @ViewBuilder
    func presentProfileView() -> some View {
        if let profileViewModel {
            ProfileView(viewModel: profileViewModel)
        }
    }
    
    @ViewBuilder
    func presentPlayerCoordinatorView() -> some View {
        playerCoordinator?.start()
    }
    
    func bindProfileViewModel() {
        profileViewModel = ProfileViewModel()
        isProfileSheetPresented = false
        
        profileViewModel?.onDidTapBackButton
            .sink { [weak self] in
                withAnimation {
                    self?.isProfileSheetPresented = false
                }
            }
            .store(in: &cancellables)
        
        profileViewModel?.onDidTapSignOut
            .sink { [weak self] in
                self?.onDidTapSignOut.send()
            }
            .store(in: &cancellables)
        
        withAnimation {
            isProfileSheetPresented = true
        }
    }
    
    func bindPlayerCoordinator() {
        let playerCoordinator = PlayerCoordinator(playerService: playerService, musicDetailsService: musicDetailsService, queueManager: queueManager)
        
        playerCoordinator.onShoudEnd
            .sink { [weak self] in
                withAnimation {
                    self?.isPlayerCoordinatorViewPresented = false
                }
                self?.persistQueueManagerState()
            }
            .store(in: &cancellables)
        
        playerCoordinator.onDidTapDiscoverButton
            .sink { [weak self] artist in
                self?.onDidTapDiscoverButton.send(artist)
            }
            .store(in: &cancellables)
        
        playerCoordinator.onDidTapArtistButton
            .flatMap { [weak self] artist in
                withAnimation {
                    self?.isPlayerCoordinatorViewPresented = false
                }
                return Just(artist)
            }
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] artist in
                self?.pushArtistViewModel(for: artist)
            }
            .store(in: &cancellables)
        
        playerCoordinator.onDidTapAlbumButton
            .flatMap { [weak self] album in
                withAnimation {
                    self?.isPlayerCoordinatorViewPresented = false
                }
                return Just(album)
            }
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] album in
                self?.pushAlbumViewModel(for: album)
            }
            .store(in: &cancellables)
        
        self.playerCoordinator = playerCoordinator
        
        queueManager.isPlaying
            .sink { [weak self] _ in
                if let self {
                    if !self.isMiniPlayerPresented {
                        self.getQueueManager()
                    }
                }
            }
            .store(in: &cancellables)
        
        withAnimation {
            isPlayerCoordinatorViewPresented = true
        }
    }
    
    func getQueueManager() {
        if let queueStateData = UserDefaults.standard.object(forKey: .UserDefaults.queueState) as? Data,
           let queueState = try? JSONDecoder().decode(QueueState.self, from: queueStateData) {
            self.queueManager.setState(with: queueState, playNow: false)
        }
    }
    
    func persistQueueManagerState() {
        if let queueManagerData = try? JSONEncoder().encode(queueManager.state) {
            UserDefaults.standard.set(queueManagerData, forKey: .UserDefaults.queueState)
        }
    }
}
