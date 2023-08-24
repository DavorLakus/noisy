//
//  HomeCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine
import SwiftUI

enum HomePath: Hashable {
    case artist(Artist)
    case album(Album)
    case playlist(Playlist)
    case playlists([Track])
}

final class HomeCoordinator: MusicDetailsCoordinatorProtocol {
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    @Published var isPlayerCoordinatorViewPresented = false
    @Published var isMiniPlayerPresented = false
    
    // MARK: - Public properties
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    var tokenDidRefresh: PassthroughSubject<Void, Never>?
    
    // MARK: - Internal properties
    internal var artistViewModelStack = Stack<ArtistViewModel>()
    internal var albumViewModelStack = Stack<AlbumViewModel>()
    internal var playlistViewModelStack = Stack<PlaylistViewModel>()
    internal var playlistsViewModel: PlaylistsViewModel?
    internal var miniPlayerViewModel: MiniPlayerViewModel?
    internal var playerCoordinator: PlayerCoordinator?
    
    internal var onDidTapPlayAllButton = PassthroughSubject<Void, Never>()
    internal var onDidTapTrackRow = PassthroughSubject<Void, Never>()
    internal var onDidTapDiscoverButton = PassthroughSubject<Artist, Never>()
    internal var musicDetailsService: MusicDetailsService
    internal var playerService: PlayerService
    internal var queueManager: QueueManager
    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private properties
    private var homeViewModel: HomeViewModel?
    
    // MARK: - Services
    private let homeService: HomeService
    
    // MARK: - Class lifecycle
    init(homeService: HomeService, playerService: PlayerService, musicDetailsService: MusicDetailsService, queueManager: QueueManager, tokenDidRefresh: PassthroughSubject<Void, Never>) {
        self.homeService = homeService
        self.musicDetailsService = musicDetailsService
        self.playerService = playerService
        self.queueManager = queueManager
        self.tokenDidRefresh = tokenDidRefresh
        
        bind()
        bindHomeViewModel()
        bindMiniPlayerViewModel(with: queueManager)
    }
    
    func start() -> some CoordinatorViewProtocol {
        HomeCoordinatorView(coordinator: self)
    }
    
    @ViewBuilder
    func rootView() -> some View {
        if let homeViewModel {
            HomeView(viewModel: homeViewModel)
                .navigationDestination(for: HomePath.self, destination: navigationDestination)
        }
    }
    
    @ViewBuilder
    func navigationDestination(_ path: HomePath) -> some View {
        switch path {
        case .artist:
            presentArtistView()
        case .album:
            presentAlbumView()
        case .playlist:
            presentPlaylistView()
        case .playlists:
            presentPlaylistsView()
        }
    }
    
    func push(_ path: HomePath) {
        switch path {
        case .artist(let artist):
            bindArtistViewModel(for: artist)
        case .album(let album):
            bindAlbumViewModel(for: album)
        case .playlist(let playlist):
            bindPlaylistViewModel(for: playlist)
        case .playlists(let tracks):
            bindPlaylistsViewModel(with: tracks)
        }
        
        navigationPath.append(path)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
}

// MARK: - MusicDetailsCoordinatorProtocol
extension HomeCoordinator {
    func pushArtistViewModel(for artist: Artist) {
        push(.artist(artist))
    }
    
    func pushAlbumViewModel(for album: Album) {
        push(.album(album))
    }
    
    func pushPlaylistViewModel(for playlist: Playlist) {
        push(.playlist(playlist))
    }
    
    func pushPlaylistsViewModel(with tracks: [Track]) {
        push(.playlists(tracks))
    }
}

// MARK: - Binding
extension HomeCoordinator {
    func bind() {
        $isMiniPlayerPresented
            .sink { _ in
                withAnimation {
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    func bindHomeViewModel() {
        let homeViewModel = HomeViewModel(homeService: homeService, queueManager: queueManager)
        
        homeViewModel.onDidTapProfileButton
            .sink { [weak self] in
                self?.onDidTapProfileButton.send()
            }
            .store(in: &cancellables)
        
        homeViewModel.onDidTapArtistRow
            .sink { [weak self] artist in
                self?.push(.artist(artist))
            }
            .store(in: &cancellables)
        
        homeViewModel.onDidTapAlbumButton
            .sink { [weak self] album in
                self?.push(.album(album))
            }
            .store(in: &cancellables)
        
        homeViewModel.onDidTapPlaylistRow
            .sink { [weak self] playlist in
                self?.push(.playlist(playlist))
            }
            .store(in: &cancellables)
        
        homeViewModel.tokenDidRefresh = tokenDidRefresh
        
        homeViewModel.onDidSelectTrackRow = onDidTapTrackRow
        
        self.homeViewModel = homeViewModel
    }
}

// MARK: - CoordinatorView
struct HomeCoordinatorView<Coordinator: MusicDetailsCoordinatorProtocol>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
            .miniPlayerView(isPresented: $coordinator.isMiniPlayerPresented, miniPlayer: coordinator.presentMiniPlayer)
            .navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $coordinator.isPlayerCoordinatorViewPresented, content: coordinator.presentPlayerCoordinatorView)
    }
}
