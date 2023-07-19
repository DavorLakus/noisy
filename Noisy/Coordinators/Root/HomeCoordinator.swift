//
//  HomeCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine
import SwiftUI

enum HomePath: Hashable, Identifiable {
    case artist(Artist)
    case playlist(Playlist)

    var id: String {
        String(describing: self)
    }
}

final class HomeCoordinator: MusicDetailsCoordinatorProtocol {
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Public properties
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    let onDidTapPlayerButton = PassthroughSubject<Track, Never>()
    
    // MARK: - Internal properties
    internal var artistViewModel: ArtistViewModel?
    internal var albumViewModel: AlbumViewModel?
    internal var playlistViewModel: PlaylistViewModel?
    internal var playlistsViewModel: PlaylistsViewModel?
    internal var musicDetailsService: MusicDetailsService
    internal var cancellables = Set<AnyCancellable>()

    // MARK: - Private properties
    private var homeViewModel: HomeViewModel?

    // MARK: - Services
    private let homeService: HomeService
    
    // MARK: - Class lifecycle
    init(homeService: HomeService, musicDetailsService: MusicDetailsService) {
        self.homeService = homeService
        self.musicDetailsService = musicDetailsService
        
        bindHomeViewModel()
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
        case .playlist:
            presentPlaylistView()
        }
    }
    
    func push(_ path: HomePath) {
        switch path {
        case .artist(let artist):
            bindArtistViewModel(for: artist)
        case .playlist(let playlist):
            bindPlaylistViewModel(for: playlist)
        }
        
        navigationPath.append(path)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
}

// MARK: - Binding
extension HomeCoordinator {
    func bindHomeViewModel() {
        homeViewModel = HomeViewModel(homeService: homeService)
        
        homeViewModel?.onDidTapProfileButton
            .sink { [weak self] in
                self?.onDidTapProfileButton.send()
            }
            .store(in: &cancellables)
        
        homeViewModel?.onDidTapArtistRow
            .sink { [weak self] artist in
                self?.push(.artist(artist))
            }
            .store(in: &cancellables)
        
        homeViewModel?.onDidTapPlaylistRow
            .sink { [weak self] playlist in
                self?.push(.playlist(playlist))
            }
            .store(in: &cancellables)
        
        homeViewModel?.onDidSelectTrackRow = onDidTapPlayerButton
    }
}

// MARK: - CoordinatorView lifecycle
extension HomeCoordinator {
    func viewDidAppear() {
//        bindErrorHandling()
    }
    
    func viewDidDisappear() {
//        errorAlertCancellable = nil
    }
}

// MARK: - CoordinatorView
struct HomeCoordinatorView<Coordinator: VerticalCoordinatorProtocol>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
//        .alert(isPresented: $coordinator.alertIsPresented) {
//            coordinator.presentAlert()
//        }
//        .onAppear(perform: coordinator.viewDidAppear)
//        .onDisappear(perform: coordinator.viewDidDisappear)
    }
}