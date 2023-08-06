//
//  RootCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI
import Combine

enum RootTab {
    case home
    case discover
    case search
}

enum Alert {
    case signout
}

final class RootCoordinator: CoordinatorProtocol {
    // MARK: - Published properties
    @Published var tab = RootTab.home
    @Published var isAlertPresented = false
    @Published var isProfileDrawerPresented = false
    @Published var isPlayerCoordinatorViewPresented = false
    @Published var alert: Alert = .signout
    
    // MARK: - Public properties
    let onDidEnd = PassthroughSubject<Void, Never>()
    
    // MARK: - Services
    private let homeService: HomeService
    private let searchService: SearchService
    private let discoverSerivce: DiscoverService
    private let playerService: PlayerService
    private let musicDetailsService: MusicDetailsService
    
    // MARK: - Coordinators
    private lazy var homeCoordinator = HomeCoordinator(homeService: homeService, musicDetailsService: musicDetailsService, queueManager: queueManager)
    private lazy var searchCoordinator = SearchCoordinator(searchService: searchService, musicDetailsService: musicDetailsService, queueManager: queueManager)
    private lazy var discoverCoordinator = DiscoverCoordinator(discoverService: discoverSerivce, searchService: searchService, musicDetailsService: musicDetailsService, queueManager: queueManager)
    private var playerCoordinator: PlayerCoordinator?
    
    // MARK: - Private properties
    private lazy var queueManager = QueueManager()
    private var miniPlayerViewModel: MiniPlayerViewModel?
    private var profileViewModel: ProfileViewModel?
    private lazy var alertViewModel = AlertViewModel(isPresented: _isAlertPresented)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(homeService: HomeService, searchService: SearchService, discoverService: DiscoverService, playerService: PlayerService, musicDetailsService: MusicDetailsService) {
        self.homeService = homeService
        self.searchService = searchService
        self.discoverSerivce = discoverService
        self.playerService = playerService
        self.musicDetailsService = musicDetailsService
        
        getQueueManager()
        bindCoordinators()
    }
    
    func start() -> some View {
        RootCoordinatorView(coordinator: self)
    }
}

// MARK: - Tabs
extension RootCoordinator {

    // Grafika muzike, statistike, itd.
    func homeTab() -> some View {
        homeCoordinator.start()
    }
    
    func discoverTab() -> some View {
        discoverCoordinator.start()
    }
    
    func searchTab() -> some View {
        searchCoordinator.start()
    }
    
    // možda music map
}

// MARK: - Private extension
private extension RootCoordinator {
    func getQueueManager() {
        if let queueStateData = UserDefaults.standard.object(forKey: .UserDefaults.queueState) as? Data,
           let queueState = try? JSONDecoder().decode(QueueState.self, from: queueStateData) {
            self.queueManager.setState(with: queueState)
            self.bindMiniPlayerViewModel(with: queueManager)
        }
    }
    
    func bindCoordinators() {
        bindHomeCoordinator()
        bindSearchCoordinator()
        bindDiscoverCoordinator()
    }
    
    func bindHomeCoordinator() {
        homeCoordinator.onDidTapProfileButton
            .sink { [weak self] in
                self?.bindProfileViewModel()
            }
            .store(in: &cancellables)
        
        homeCoordinator.onDidTapPlayAllButton
            .sink { [weak self] tracks in
                self?.bindPlayerCoordinator(with: tracks)
            }
            .store(in: &cancellables)
        
        homeCoordinator.onDidTapTrackRow
            .sink { [weak self] track in
                self?.bindPlayerCoordinator(with: [track])
            }
            .store(in: &cancellables)
    }
    
    func bindSearchCoordinator() {
        searchCoordinator.onDidTapProfileButton
            .sink { [weak self] in
                self?.bindProfileViewModel()
            }
            .store(in: &cancellables)
        
        searchCoordinator.onDidTapPlayAllButton
            .sink { [weak self] tracks in
                self?.bindPlayerCoordinator(with: tracks)
            }
            .store(in: &cancellables)
        
        searchCoordinator.onDidTapTrackRow
            .sink { [weak self] track in
                self?.bindPlayerCoordinator(with: [track])
            }
            .store(in: &cancellables)
    }
    
    func bindDiscoverCoordinator() {
        discoverCoordinator.onDidTapProfileButton
            .sink { [weak self] in
                self?.bindProfileViewModel()
            }
            .store(in: &cancellables)
        
        discoverCoordinator.onDidTapPlayAllButton
            .sink { [weak self] tracks in
                self?.bindPlayerCoordinator(with: tracks)
            }
            .store(in: &cancellables)
        
        discoverCoordinator.onDidTapTrackRow
            .sink { [weak self] track in
                self?.bindPlayerCoordinator(with: [track])
            }
            .store(in: &cancellables)
    }
}

// MARK: - MiniPlayer
extension RootCoordinator {
    @ViewBuilder
    func presentMiniPlayer() -> some View {
        if let miniPlayerViewModel {
            MiniPlayerView(viewModel: miniPlayerViewModel)
        }
    }
    
    func bindMiniPlayerViewModel(with queueManager: QueueManager) {
        miniPlayerViewModel = MiniPlayerViewModel(queueManager: queueManager)
        
        miniPlayerViewModel?.onDidTapMiniPlayer
            .sink { [weak self] in
                self?.bindPlayerCoordinator(playNow: false)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Player
extension RootCoordinator {
    @ViewBuilder
    func presentPlayerCoordinatorView() -> some View {
        playerCoordinator?.start()
    }
    
    func bindPlayerCoordinator(with tracks: [Track]? = nil, playNow: Bool = true) {
        if queueManager.state.tracks.isEmpty,
           let tracks {
            queueManager.setState(with: QueueState(tracks: tracks))
        }

        if let tracks {
            queueManager.setState(with: tracks)
        }
        
        persistQueueManagerState()
        if playNow {
            queueManager.play()
        }
        
        playerCoordinator = PlayerCoordinator(playerService: playerService, musicDetailsService: musicDetailsService, queueManager: queueManager)
        
        playerCoordinator?.onShoudEnd
            .sink { [weak self] in
                withAnimation {
                    self?.isPlayerCoordinatorViewPresented = false
                }
                self?.persistQueueManagerState()
            }
            .store(in: &cancellables)
        
        withAnimation {
            isPlayerCoordinatorViewPresented = true
        }
    }
    
    func persistQueueManagerState() {
        if let queueManagerData = try? JSONEncoder().encode(queueManager.state) {
            UserDefaults.standard.set(queueManagerData, forKey: .UserDefaults.queueState)
        }
    }
}

// MARK: - Profile
extension RootCoordinator {
    @ViewBuilder
    func presentProfileView() -> some View {
        if let profileViewModel {
            ProfileView(viewModel: profileViewModel)
        }
    }
    
    func bindProfileViewModel() {
        profileViewModel = ProfileViewModel()
        isProfileDrawerPresented = false
        
        profileViewModel?.onDidTapBackButton
            .sink { [weak self] in
                withAnimation {
                    self?.isProfileDrawerPresented = false
                }
            }
            .store(in: &cancellables)
        
        profileViewModel?.onDidTapSignOut
            .sink { [weak self] in
                self?.alert = .signout
                withAnimation {
                    self?.bindAlertViewModel()
                }
            }
            .store(in: &cancellables)
        
        withAnimation {
            isProfileDrawerPresented = true
        }
    }
}

// MARK: - Alert
extension RootCoordinator {
    @ViewBuilder
    func presentAlertView() -> some View {
        AlertView(viewModel: alertViewModel)
    }
    
    func bindAlertViewModel() {
        alertViewModel = AlertViewModel(isPresented: _isAlertPresented)
        
        switch self.alert {
        case .signout:
            alertViewModel.title = .Profile.signoutTitle
            alertViewModel.message = .Profile.signoutMessage
            alertViewModel.primaryActionText = .Profile.signoutTitle
            alertViewModel.onDidTapPrimaryAction = onDidEnd
        }
        
        withAnimation {
            self.isAlertPresented = true
        }
    }
}
