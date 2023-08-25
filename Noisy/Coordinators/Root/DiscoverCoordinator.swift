//
//  DiscoverCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 17.07.2023..
//

import SwiftUI
import Combine

enum DiscoverPath: Hashable {
    case artist(Artist)
    case album(Album)
    case playlist(Playlist)
    case playlists([Track])
    case visualize([Track])
}

enum SheetPath: Hashable {
    case playlists
}

final class DiscoverCoordinator: MusicDetailsCoordinatorProtocol & SheetCoordinatorProtocol {
    
    var sheetPath: SheetPath = .playlists
    
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    @Published var isSheetPresented: Bool = false
    @Published var isMiniPlayerPresented: Bool = false
    @Published var isProfileSheetPresented = false
    @Published var isPlayerCoordinatorViewPresented: Bool = false
    
    // MARK: - Internal properties
    internal var artistViewModelStack = Stack<ArtistViewModel>()
    internal var albumViewModelStack = Stack<AlbumViewModel>()
    internal var playlistViewModelStack = Stack<PlaylistViewModel>()
    internal var playlistsViewModel: PlaylistsViewModel?
    internal var miniPlayerViewModel: MiniPlayerViewModel?
    internal var profileViewModel: ProfileViewModel?
    internal var playerCoordinator: PlayerCoordinator?
    
    internal var onDidTapPlayAllButton = PassthroughSubject<Void, Never>()
    internal var onDidTapTrackRow = PassthroughSubject<Void, Never>()
    internal var onDidTapDiscoverButton = PassthroughSubject<Artist, Never>()
    internal var onDidTapSignOut = PassthroughSubject<Void, Never>()
    internal var musicDetailsService: MusicDetailsService
    internal var playerService: PlayerService
    internal var queueManager: QueueManager

    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private properties
    private var discoverViewModel: DiscoverViewModel?
    private var visualizeViewModel: VisualizeViewModel?
    private var discoverService: DiscoverService
    private var searchService: SearchService
    
    // MARK: - Class lifecycle
    init(discoverService: DiscoverService, playerService: PlayerService, searchService: SearchService, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.discoverService = discoverService
        self.searchService = searchService
        self.playerService = playerService
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        bind()
        bindDiscoverViewModel()
        bindMiniPlayerViewModel(with: queueManager)
    }
    
    func start() -> some CoordinatorViewProtocol {
        DiscoverCoordinatorView(coordinator: self)
    }
    
    @ViewBuilder
    func rootView() -> some View {
        if let discoverViewModel {
            DiscoverView(viewModel: discoverViewModel)
                .navigationDestination(for: DiscoverPath.self, destination: navigationDestination)
        }
    }
    
    @ViewBuilder
    func navigationDestination(_ path: DiscoverPath) -> some View {
        switch path {
        case .artist:
            presentArtistView()
        case .album:
            presentAlbumView()
        case .playlist:
            presentPlaylistView()
        case .playlists:
            presentPlaylistsView()
        case .visualize:
            presentVisualizeView()
        }
    }
    
    func push(_ path: DiscoverPath) {
        switch path {
        case .artist(let artist):
            bindArtistViewModel(for: artist)
        case .album(let album):
            bindAlbumViewModel(for: album)
        case .playlist(let playlist):
            bindPlaylistViewModel(for: playlist)
        case .playlists(let tracks):
            bindPlaylistsViewModel(with: tracks)
        case .visualize(let tracks):
            bindVisualizeViewModel(with: tracks)
        }
        
        navigationPath.append(path)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
    
    @ViewBuilder
    func presentSheetView() -> some View {
        if playlistsViewModel != nil {
            presentPlaylistsView()
        }
    }
}

// MARK: - Public extension
extension DiscoverCoordinator {
    func discover(with artist: Artist) {
        discoverViewModel?.seedArtists = [artist]
        withAnimation {
            discoverViewModel?.onDidTapDiscoverButton()
        }
    }
}

// MARK: - ViewModel binding
private extension DiscoverCoordinator {
    func bind() {
        $isMiniPlayerPresented
            .sink { _ in
                withAnimation {
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    func bindDiscoverViewModel() {
        let discoverViewModel = DiscoverViewModel(discoverService: discoverService, searchService: searchService, musicDetailsService: musicDetailsService, queueManager: queueManager)
        discoverViewModel.onDidTapProfileButton
            .sink { [weak self] in
                self?.bindProfileViewModel()
            }
            .store(in: &cancellables)
        
        discoverViewModel.onDidTapArtistButton
            .sink { [weak self] artist in
                self?.push(.artist(artist))
            }
            .store(in: &cancellables)
        
        discoverViewModel.onDidTapAlbumButton
            .sink { [weak self] album in
                self?.push(.album(album))
            }
            .store(in: &cancellables)
        
        discoverViewModel.onDidTapAddToPlaylist
            .sink { [weak self] tracks in
                self?.push(.playlists(tracks))
            }
            .store(in: &cancellables)
        
        discoverViewModel.onDidTapVisualizeButton
            .sink { [weak self] tracks in
                self?.push(.visualize(tracks))
                withAnimation {
                    self?.isMiniPlayerPresented = false
                }
            }
            .store(in: &cancellables)
        
        discoverViewModel.onDidTapRecommendedTrackRow = onDidTapTrackRow
        
        self.discoverViewModel = discoverViewModel
    }
    
    func bindVisualizeViewModel(with tracks: [Track]) {
        let viewModel = VisualizeViewModel(tracks: tracks, discoverService: discoverService, musicDetailsService: musicDetailsService, queueManager: queueManager)
        
        viewModel.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
                withAnimation {
                    self?.isMiniPlayerPresented = true
                }
            }
            .store(in: &cancellables)
        
        visualizeViewModel = viewModel
    }
}

// MARK: - ViewBuilder
extension DiscoverCoordinator {
    @ViewBuilder
    func presentVisualizeView() -> some View {
        if let visualizeViewModel {
            VisualizeView(viewModel: visualizeViewModel)
        }
    }

}

// MARK: - MusicDetailsCoordinatorProtocol
extension DiscoverCoordinator {
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

// MARK: - CoordinatorViewCoordinator
struct DiscoverCoordinatorView<Coordinator: MusicDetailsCoordinatorProtocol & SheetCoordinatorProtocol>: SheetCoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
            .dynamicModalSheet(isPresented: $coordinator.isProfileSheetPresented, content:  coordinator.presentProfileView)
            .miniPlayerView(isPresented: $coordinator.isMiniPlayerPresented, miniPlayer: coordinator.presentMiniPlayer)
            .fullScreenCover(isPresented: $coordinator.isPlayerCoordinatorViewPresented, content: coordinator.presentPlayerCoordinatorView)
    }
}
