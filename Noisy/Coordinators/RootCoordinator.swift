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
    private lazy var homeCoordinator = HomeCoordinator(homeService: homeService, musicDetailsService: musicDetailsService)
    private lazy var searchCoordinator = SearchCoordinator(searchService: searchService, musicDetailsService: musicDetailsService)
    private lazy var discoverCoordinator = DiscoverCoordinator(discoverService: discoverSerivce, musicDetailsService: musicDetailsService)
    private var playerCoordinator: PlayerCoordinator?
    
    // MARK: - Private properties
    private var queueManager: QueueManager?
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
        if let queueManagerData = UserDefaults.standard.object(forKey: .UserDefaults.queueManager) as? Data,
           let queueManager = try? JSONDecoder().decode(QueueManager.self, from: queueManagerData) {
            self.queueManager = queueManager
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
        
        homeCoordinator.onDidTapPlayerButton
            .sink { [weak self] track in
                self?.bindPlayerCoordinator(with: track)
            }
            .store(in: &cancellables)
    }
    
    func bindSearchCoordinator() {
        searchCoordinator.onDidTapProfileButton
            .sink { [weak self] in
                self?.bindProfileViewModel()
            }
            .store(in: &cancellables)
    }
    
    func bindDiscoverCoordinator() {
        discoverCoordinator.onDidTapProfileButton
            .sink { [weak self] in
                self?.bindProfileViewModel()
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
    
    func bindPlayerCoordinator(with track: Track) {
        if let queueManager {
            queueManager.tracks = [track]
        } else {
            queueManager = QueueManager(tracks: [track])
        }
        guard let queueManager else { return }
        
        playerCoordinator = PlayerCoordinator(playerService: playerService, musicDetailsService: musicDetailsService, queueManager: queueManager)
        
        playerCoordinator?.onShoudEnd
            .sink { [weak self] in
                withAnimation {
                    self?.isPlayerCoordinatorViewPresented = false
                }
            }
            .store(in: &cancellables)
        
        withAnimation {
            isPlayerCoordinatorViewPresented = true
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
