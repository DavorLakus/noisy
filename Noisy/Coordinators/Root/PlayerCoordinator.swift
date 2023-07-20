//
//  PlayerCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

enum PlayerPath: Hashable {
    case options
    case queue
    case artist(Artist)
    case album(Album)
    case playlist(Playlist)
    case playlists([Playlist])
}

final class PlayerCoordinator: MusicDetailsCoordinatorProtocol {
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    @Published var isShareViewPresented = false
    
    // MARK: - Public properties
    var onShoudEnd = PassthroughSubject<Void, Never>()
    
    // MARK: - Internal properties
    internal var artistViewModelStack = Stack<ArtistViewModel>()
    internal var albumViewModelStack = Stack<AlbumViewModel>()
    internal var playlistViewModelStack = Stack<PlaylistViewModel>()
    internal var playlistsViewModelStack = Stack<PlaylistsViewModel>()
    
    internal var onDidTapPlayerButton = PassthroughSubject<Track, Never>()
    internal var musicDetailsService: MusicDetailsService
    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Services
    private let playerService: PlayerService
    
    // MARK: - Private propeties
    private lazy var playerViewModel = PlayerViewModel(queueManager: queueManager)
    private var optionsViewModel: OptionsViewModel?
    private var queueViewModel: QueueViewModel?
    private var queueManager: QueueManager
    
    init(playerService: PlayerService, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.playerService = playerService
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        bindPlayerView()
    }
    
    @ViewBuilder
    func start() -> some CoordinatorViewProtocol {
        PlayerCoordinatorView(coordinator: self)
    }
    
    @ViewBuilder
    func rootView() -> some View {
        PlayerView(viewModel: playerViewModel)
            .navigationDestination(for: PlayerPath.self, destination: navigationDestination)
    }
    
    @ViewBuilder
    func navigationDestination(_ path: PlayerPath) -> some View {
        switch path {
        case .options:
            presentOptionsView()
        case .queue:
            presentQueueView()
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
    
    func push(_ path: PlayerPath) {
        switch path {
        case .options:
            bindOptionsViewModel()
        case .queue:
            bindQueueViewModel()
        case .artist(let artist):
            bindArtistViewModel(for: artist)
        case .album(let album):
            bindAlbumViewModel(for: album)
        case .playlist(let playlist):
            bindPlaylistViewModel(for: playlist)
        case .playlists(let playlists):
            bindPlaylistsViewModel(for: playlists)
        }
        
        navigationPath.append(path)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
}

// MARK: - MusicDetailsCoordinatorProtocol
extension PlayerCoordinator {
    func pushArtistViewModel(for artist: Artist) {
        push(.artist(artist))
    }
    
    func pushAlbumViewModel(for album: Album) {
        push(.album(album))
    }
    
    func pushPlaylistViewModel(for playlist: Playlist) {
        push(.playlist(playlist))
    }
    
    func pushPlaylistsViewModel(for playlists: [Playlist]) {
        push(.playlists(playlists))
    }
}

// MARK: ViewBuilder
extension PlayerCoordinator {
    @ViewBuilder
    func presentOptionsView() -> some View {
        if let optionsViewModel {
            OptionsView(viewModel: optionsViewModel)
        }
    }
    
    @ViewBuilder
    func presentQueueView() -> some View {
        if let queueViewModel {
            QueueView(viewModel: queueViewModel)
        }
    }
}

// MARK: - Public extension
extension PlayerCoordinator {
    func bindPlayerView() {
        playerViewModel.onDidTapDismissButton = onShoudEnd
        
        playerViewModel.onDidTapOptionsButton
            .sink { [weak self] in
                self?.push(.options)
            }
            .store(in: &cancellables)
        
        playerViewModel.onDidTapShareButton
            .sink { [weak self] in
                self?.presentShareView()
            }
            .store(in: &cancellables)
        
        playerViewModel.onDidTapQueueButton
            .sink { [weak self] in
                self?.push(.queue)
            }
            .store(in: &cancellables)
    }
    
    func bindOptionsViewModel() {
        optionsViewModel = OptionsViewModel()
        
        optionsViewModel?.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
            }
            .store(in: &cancellables)
        
        optionsViewModel?.onDidTapPlaylistsButton
            .sink { [weak self] playlists in
                self?.push(.playlists(playlists))
            }
            .store(in: &cancellables)
    }
    
    func presentShareView() {
        print("sharing is caring")
        
        withAnimation {
         isShareViewPresented = true
        }
    }
    
    func bindQueueViewModel() {
        queueViewModel = QueueViewModel()
        
        queueViewModel?.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
            }
            .store(in: &cancellables)
    }
}

struct PlayerCoordinatorView<Coordinator: VerticalCoordinatorProtocol>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
    }
}
