//
//  PlayerCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

enum PlayerPath: Hashable {
//    case options
    case queue
    case artist(Artist)
    case album(Album)
    case playlist(Playlist)
    case playlists([Track])
}

enum PlayerSheet: Hashable {
    case playlists
}

final class PlayerCoordinator: MusicDetailsCoordinatorProtocol, SheetCoordinatorProtocol {
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    @Published var isSheetPresented: Bool = false
    
    // MARK: - Public properties
    var onShoudEnd = PassthroughSubject<Void, Never>()
    
    // MARK: - Internal properties
    internal var artistViewModelStack = Stack<ArtistViewModel>()
    internal var albumViewModelStack = Stack<AlbumViewModel>()
    internal var playlistViewModelStack = Stack<PlaylistViewModel>()
    internal var playlistsViewModel: PlaylistsViewModel?
    
    internal var onDidTapPlayAllButton = PassthroughSubject<Void, Never>()
    internal var onDidTapTrackRow = PassthroughSubject<Void, Never>()
    internal var onDidTapDiscoverButton = PassthroughSubject<Artist, Never>()
    internal var musicDetailsService: MusicDetailsService
    internal var queueManager: QueueManager
    internal var sheetPath: PlayerSheet = .playlists

    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Services
    private let playerService: PlayerService
    
    // MARK: - Private propeties
    private lazy var playerViewModel = PlayerViewModel(musicDetailsService: musicDetailsService, queueManager: queueManager)
    private var optionsViewModel: OptionsViewModel?
    private var queueViewModel: QueueViewModel?
    
    init(playerService: PlayerService, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.playerService = playerService
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        bindPlayerViewModel()
    }
    
    @ViewBuilder
    func start() -> some SheetCoordinatorViewProtocol {
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
        case .queue:
            bindQueueViewModel()
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
    
    @ViewBuilder
    func presentSheetView() -> some View {
        switch sheetPath {
        case .playlists:
            presentPlaylistsView()
        }
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
    
    func pushPlaylistsViewModel(with tracks: [Track]) {
        push(.playlists(tracks))
    }
}

// MARK: - SheetCoordinator
extension PlayerCoordinator {
    func bindPlaylistsViewModel(with tracks: [Track]) {
        let viewModel = PlaylistsViewModel(tracks: tracks, musicDetailsService: musicDetailsService)
        
        viewModel.onDidTapBackButton
            .sink { [weak self] in
                withAnimation {
                    self?.isSheetPresented = false
                    self?.playlistsViewModel = nil
                }
            }
            .store(in: &cancellables)
        
        playlistsViewModel = viewModel
    }
}

// MARK: ViewBuilder
extension PlayerCoordinator {
    @ViewBuilder
    func presentQueueView() -> some View {
        if let queueViewModel {
            QueueView(viewModel: queueViewModel)
        }
    }
}

// MARK: - Public extension
extension PlayerCoordinator {
    func bindPlayerViewModel() {
        playerViewModel.onDidTapDismissButton = onShoudEnd
        
        playerViewModel.onDidTapQueueButton
            .sink { [weak self] in
                self?.push(.queue)
            }
            .store(in: &cancellables)
        
        playerViewModel.onDidTapArtistButton
            .sink { [weak self] artist in
                self?.push(.artist(artist))
            }
            .store(in: &cancellables)
        
        playerViewModel.onDidTapAlbumButton
            .sink { [weak self] album in
                self?.push(.album(album))
            }
            .store(in: &cancellables)
        
        playerViewModel.onDidTapAddToPlaylist
            .sink { [weak self] tracks in
                self?.bindPlaylistsViewModel(with: tracks)
                withAnimation {
                    self?.isSheetPresented = true
                }
            }
            .store(in: &cancellables)
    }
    
    func bindQueueViewModel() {
        queueViewModel = QueueViewModel(queueManager: queueManager)
        
        queueViewModel?.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
            }
            .store(in: &cancellables)
    }
}

// MARK: - PlayerCoordinatorView
struct PlayerCoordinatorView<Coordinator: VerticalCoordinatorProtocol & SheetCoordinatorProtocol>: SheetCoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
            .sheet(isPresented: $coordinator.isSheetPresented, content: coordinator.presentSheetView)
    }
}
