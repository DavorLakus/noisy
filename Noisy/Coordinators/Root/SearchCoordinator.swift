//
//  SearchCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 17.07.2023..
//

import SwiftUI
import Combine

enum SearchPath: Hashable {
    case details
}

final class SearchCoordinator: MusicDetailsCoordinatorProtocol {
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Public properties
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Internal properties
    internal var artistViewModel: ArtistViewModel?
    internal var albumViewModel: AlbumViewModel?
    internal var playlistViewModel: PlaylistViewModel?
    internal var playlistsViewModel: PlaylistsViewModel?
    internal var musicDetailsService: MusicDetailsService
    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private properties
    private var searchService: SearchService
    
    private var searchViewModel: SearchViewModel?
    
    // MARK: - Class lifecycle
    init(searchService: SearchService, musicDetailsService: MusicDetailsService) {
        self.searchService = searchService
        self.musicDetailsService = musicDetailsService
        
        bindSearchViewModel()
    }
    
    func start() -> some CoordinatorViewProtocol {
        SearchCoordinatorView(coordinator: self)
    }
    
    @ViewBuilder
    func rootView() -> some View {
        if let searchViewModel {
            SearchView(viewModel: searchViewModel)
        }
    }
    
    func push(_ path: SearchPath) {
        navigationPath.append(path)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
    
    @ViewBuilder
    func navigationDestination(_ path: SearchPath) -> some View {
        switch path {
        case .details:
            Color.red
        }
    }
}

// MARK: - Private extensions
private extension SearchCoordinator {
    func bindSearchViewModel() {
        searchViewModel = SearchViewModel(searchService: searchService)
        
        searchViewModel?.onDidTapProfileButton
            .sink { [weak self] in
                self?.onDidTapProfileButton.send()
            }
            .store(in: &cancellables)
    }
}

// MARK: - CoordinatorView
struct SearchCoordinatorView<Coordinator: VerticalCoordinatorProtocol>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
    }
}
