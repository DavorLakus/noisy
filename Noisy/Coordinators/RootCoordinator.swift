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
    case liveMusic
    case radio
    case settings
}

enum Alert {
    case signout
}

final class RootCoordinator: CoordinatorProtocol {
    
    // MARK: - Published properties
    @Published var tab = RootTab.home
    @Published var isAlertPresented = false
    @Published var isProfileDrawerPresented = false
    @Published var alert: Alert = .signout
    
    // MARK: - Public properties
    let onDidEnd = PassthroughSubject<Void, Never>()
    
    // MARK: - Services
    private let homeService: HomeService
    private let searchService: SearchService
    private let discoverSerivce: DiscoverService
    
    // MARK: - Coordinators
    private lazy var homeCoordinator = HomeCoordinator(homeService: homeService)
    private lazy var searchCoordinator = SearchCoordinator(searchService: searchService)
    private lazy var discoverCoordinator = DiscoverCoordinator(discoverService: discoverSerivce)
    
    // MARK: - Private properties
    private var profileViewModel: ProfileViewModel?
    private lazy var alertViewModel = AlertViewModel(isPresented: _isAlertPresented)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private properties
    private var accountViewModel: AccountViewModel?
    private var alertViewModel: AlertViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(homeService: HomeService, searchService: SearchService, discoverService: DiscoverService) {
        self.homeService = homeService
        self.searchService = searchService
        self.discoverSerivce = discoverService
        
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
    
    func liveMusicTab() -> some View {
        Color.purple600
    }
    
    func radio() -> some View {
        Color.purple600
    }
    
    func settingsTab() -> some View {
        Color.orange400
    }
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
        
        profileViewModel?.onDidTapProfileView
            .flatMap({ [weak self] in
                self?.profileViewModel?.viewWillDisappear(isPushNavigation: true)
                return Just($0)
            })
            .debounce(for: .seconds(0.02), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                //                self?.profileButtonTapped()
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
