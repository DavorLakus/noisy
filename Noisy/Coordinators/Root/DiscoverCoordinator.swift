//
//  DiscoverCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 17.07.2023..
//

import SwiftUI
import Combine

enum DiscoverPath: Hashable {
    case detail
}

final class DiscoverCoordinator: MusicDetailsCoordinatorProtocol {
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
    private var discoverViewModel: DiscoverViewModel?
    private var discoverService: DiscoverService
    
    
    // MARK: - Class lifecycle
    init(discoverService: DiscoverService, musicDetailsService: MusicDetailsService) {
        self.discoverService = discoverService
        self.musicDetailsService = musicDetailsService
        
        bindDiscoverViewModel()
    }
    
    func bindDiscoverViewModel() {
        discoverViewModel = DiscoverViewModel(discoverService: discoverService)
        
        discoverViewModel?.onDidTapProfileButton
            .sink { [weak self] in
                self?.onDidTapProfileButton.send()
            }
            .store(in: &cancellables)
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
        case .detail:
            EmptyView()
        }
    }
    
    func push(_ path: DiscoverPath) {
        navigationPath.append(path)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
}

struct DiscoverCoordinatorView<Coordinator: DiscoverCoordinator>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
    }
}
