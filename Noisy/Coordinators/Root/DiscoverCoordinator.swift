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

final class DiscoverCoordinator: MusicDetailsCoordinatorProtocol {
    
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Public properties
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Internal properties
    internal var artistViewModelStack = Stack<ArtistViewModel>()
    internal var albumViewModelStack = Stack<AlbumViewModel>()
    internal var playlistViewModelStack = Stack<PlaylistViewModel>()
    internal var playlistsViewModel: PlaylistsViewModel?
    
    internal var onDidTapPlayAllButton = PassthroughSubject<Void, Never>()
    internal var onDidTapTrackRow = PassthroughSubject<Void, Never>()
    internal var musicDetailsService: MusicDetailsService
    internal var queueManager: QueueManager

    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private properties
    private lazy var discoverViewModel = DiscoverViewModel(discoverService: discoverService, searchService: searchService, musicDetailsService: musicDetailsService, queueManager: queueManager)
    private var visualizeViewModel: VisualizeViewModel?
    private var discoverService: DiscoverService
    private var searchService: SearchService
    
    // MARK: - Class lifecycle
    init(discoverService: DiscoverService, searchService: SearchService, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.discoverService = discoverService
        self.searchService = searchService
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        bindDiscoverViewModel()
    }
    
    func start() -> some CoordinatorViewProtocol {
        DiscoverCoordinatorView(coordinator: self)
    }
    
    @ViewBuilder
    func rootView() -> some View {
        DiscoverView(viewModel: discoverViewModel)
            .navigationDestination(for: DiscoverPath.self, destination: navigationDestination)
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
}

// MARK: - ViewModel binding
private extension DiscoverCoordinator {
    func bindDiscoverViewModel() {
        discoverViewModel.onDidTapProfileButton
            .sink { [weak self] in
                self?.onDidTapProfileButton.send()
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
            }
            .store(in: &cancellables)
        
        discoverViewModel.onDidTapRecommendedTrackRow = onDidTapTrackRow
    }
    
    func bindVisualizeViewModel(with tracks: [Track]) {
        let viewModel = VisualizeViewModel(tracks: tracks, discoverService: discoverService, musicDetailsService: musicDetailsService, queueManager: queueManager)
        
        viewModel.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
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
struct DiscoverCoordinatorView<Coordinator: MusicDetailsCoordinatorProtocol>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
    }
}
