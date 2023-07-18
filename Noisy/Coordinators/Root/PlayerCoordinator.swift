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
    case playlists
}

final class PlayerCoordinator: VerticalCoordinatorProtocol {
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    @Published var isShareViewPresented = false
    
    // MARK: - Public properties
    var onShoudEnd = PassthroughSubject<Void, Never>()
    
    // MARK: - Private propeties
    private let playerService: PlayerService
    private lazy var playerViewModel = PlayerViewModel(playerService: playerService)
    private var optionsViewModel: OptionsViewModel?
    private var queueViewModel: QueueViewModel?
    private var playlistsViewModel: PlaylistsViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(playerService: PlayerService) {
        self.playerService = playerService
        
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
        case .playlists:
            presentPlaylistsView()
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
    
    func push(_ path: PlayerPath) {
        switch path {
        case .options:
            bindOptionsViewModel()
        case .queue:
            bindQueueViewModel()
        case .playlists:
            bindPlaylistsViewModel()
        }
        
        navigationPath.append(path)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
    
    @ViewBuilder
    func presentOptionsView() -> some View {
        if let optionsViewModel {
            OptionsView(viewModel: optionsViewModel)
        }
    }
    
    func bindOptionsViewModel() {
        optionsViewModel = OptionsViewModel()
        
        optionsViewModel?.onDidTapBackButton
            .sink { [weak self] in
                self?.pop()
            }
            .store(in: &cancellables)
        
        optionsViewModel?.onDidTapPlaylistsButton
            .sink { [weak self] in
                self?.push(.playlists)
            }
            .store(in: &cancellables)
    }
    
    func presentShareView() {
        print("sharing is caring")
        
        withAnimation {
         isShareViewPresented = true
        }
    }
    
    @ViewBuilder
    func presentQueueView() -> some View {
        if let queueViewModel {
            QueueView(viewModel: queueViewModel)
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
    
    @ViewBuilder
    func presentPlaylistsView() -> some View {
        if let playlistsViewModel {
            PlaylistsView(viewModel: playlistsViewModel)
        }
    }
    
    func bindPlaylistsViewModel() {
        playlistsViewModel = PlaylistsViewModel(playerService: playerService)
        
        playlistsViewModel?.onDidTapCancelButton
            .sink { [weak self] in
                withAnimation {
                    self?.pop()
                }
            }
    }
}

struct PlayerCoordinatorView<Coordinator: VerticalCoordinatorProtocol>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
    }
}
