//
//  SearchCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 17.07.2023..
//

import SwiftUI
import Combine

enum SearchPath: Hashable {
    case artist(Artist)
    case album(Album)
    case playlist(Playlist)
    case playlists([Track])
}

final class SearchCoordinator: MusicDetailsCoordinatorProtocol {
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    @Published var isPlayerCoordinatorViewPresented = false
    @Published var isProfileSheetPresented = false
    @Published var isMiniPlayerPresented = false
    
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
    private var searchService: SearchService
    private var searchViewModel: SearchViewModel?
    
    // MARK: - Class lifecycle
    init(searchService: SearchService, playerService: PlayerService, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.searchService = searchService
        self.playerService = playerService
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        bind()
        bindSearchViewModel()
        bindMiniPlayerViewModel(with: queueManager)
    }
    
    func start() -> some CoordinatorViewProtocol {
        SearchCoordinatorView(coordinator: self)
    }
    
    @ViewBuilder
    func rootView() -> some View {
        if let searchViewModel {
            SearchView(viewModel: searchViewModel)
                .navigationDestination(for: SearchPath.self, destination: navigationDestination)
        }
    }
    
    func push(_ path: SearchPath) {
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
    
    @ViewBuilder
    func navigationDestination(_ path: SearchPath) -> some View {
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
}

// MARK: - MusicDetailsCoordinatorProtocol
extension SearchCoordinator {
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

// MARK: - Private extensions
private extension SearchCoordinator {
    func bind() {
        $isMiniPlayerPresented
            .sink { _ in
                withAnimation {
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    func bindSearchViewModel() {
        searchViewModel = SearchViewModel(searchService: searchService, queueManager: queueManager)
        
        searchViewModel?.onDidTapProfileButton
            .sink { [weak self] in
                self?.bindProfileViewModel()
            }
            .store(in: &cancellables)
        
        searchViewModel?.onDidSelectTrackRow = onDidTapTrackRow
           
        searchViewModel?.onDidTapAlbumRow
            .sink { [weak self] album in
                self?.push(.album(album))
            }
            .store(in: &cancellables)
        
        searchViewModel?.onDidTapArtistRow
            .sink { [weak self] artist in
                self?.push(.artist(artist))
            }
            .store(in: &cancellables)
        
        searchViewModel?.onDidTapPlaylistRow
            .sink { [weak self] playlist in
                self?.push(.playlist(playlist))
            }
            .store(in: &cancellables)
    }
}

// MARK: - CoordinatorView
struct SearchCoordinatorView<Coordinator: MusicDetailsCoordinatorProtocol>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
            .dynamicModalSheet(isPresented: $coordinator.isProfileSheetPresented, content:  coordinator.presentProfileView)
            .miniPlayerView(isPresented: $coordinator.isMiniPlayerPresented, miniPlayer: coordinator.presentMiniPlayer)
            .fullScreenCover(isPresented: $coordinator.isPlayerCoordinatorViewPresented, content: coordinator.presentPlayerCoordinatorView)
    }
}
