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
    
    // MARK: - Coordinators
    private lazy var homeCoordinator = HomeCoordinator(homeService: homeService)
    private lazy var searchCoordinator = SearchCoordinator(searchService: searchService)
    private lazy var discoverCoordinator = DiscoverCoordinator(discoverService: discoverSerivce)
    private lazy var playerCoordinator = PlayerCoordinator(playerService: playerService)
    
    // MARK: - Private properties
    private var profileViewModel: ProfileViewModel?
    private lazy var alertViewModel = AlertViewModel(isPresented: _isAlertPresented)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(homeService: HomeService, searchService: SearchService, discoverService: DiscoverService, playerService: PlayerService) {
        self.homeService = homeService
        self.searchService = searchService
        self.discoverSerivce = discoverService
        self.playerService = playerService
        
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
            .sink { [weak self] in
                self?.bindPlayerCoordinator()
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
        playerCoordinator.start()
    }
    
    func bindPlayerCoordinator() {
        playerCoordinator = PlayerCoordinator(playerService: playerService)
        
        playerCoordinator.onShoudEnd
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
            alertViewModel.title = .Profile.signOutTitle
            alertViewModel.message = .Profile.signOutMessage
            alertViewModel.primaryActionText = .Profile.signOutTitle
            alertViewModel.onDidTapPrimaryAction = onDidEnd
        }
        
        withAnimation {
            self.isAlertPresented = true
        }
    }
}
