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
    @Published var alert: Alert = .signout
    
    // MARK: - Public properties
    let onDidEnd = PassthroughSubject<Void, Never>()
    let tokenDidRefresh = PassthroughSubject<Void, Never>()
    
    // MARK: - Services
    private let homeService: HomeService
    private let searchService: SearchService
    private let discoverSerivce: DiscoverService
    private let playerService: PlayerService
    private let musicDetailsService: MusicDetailsService
    
    // MARK: - Coordinators
    private var homeCoordinator: HomeCoordinator?
    private var searchCoordinator: SearchCoordinator?
    private var discoverCoordinator: DiscoverCoordinator?
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    private lazy var queueManager = QueueManager()
    
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
    @ViewBuilder
    func homeTab() -> some View {
        if let homeCoordinator {
            homeCoordinator.start()
        }
    }
    
    @ViewBuilder
    func discoverTab() -> some View {
        if let discoverCoordinator {
            discoverCoordinator.start()
        }
    }
    
    @ViewBuilder
    func searchTab() -> some View {
        if let searchCoordinator {
            searchCoordinator.start()
        }
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
        let homeCoordinator = HomeCoordinator(homeService: homeService, playerService: playerService, musicDetailsService: musicDetailsService, queueManager: queueManager, tokenDidRefresh: tokenDidRefresh)
        
        homeCoordinator.onDidTapSignOut
            .sink { [weak self] in
                self?.alert = .signout
                withAnimation {
                    self?.isAlertPresented = true
                }
            }
            .store(in: &cancellables)
        
        homeCoordinator.onDidTapDiscoverButton
            .sink { [weak self] artist in
                self?.switchToDiscoverTab(for: artist, from: homeCoordinator)
            }
            .store(in: &cancellables)
        
        self.homeCoordinator = homeCoordinator
    }
    
    func bindSearchCoordinator() {
        let searchCoordinator = SearchCoordinator(searchService: searchService, playerService: playerService, musicDetailsService: musicDetailsService, queueManager: queueManager)
        
        searchCoordinator.onDidTapSignOut
            .sink { [weak self] in
                self?.alert = .signout
                withAnimation {
                    self?.isAlertPresented = true
                }
            }
            .store(in: &cancellables)
        
        searchCoordinator.onDidTapDiscoverButton
            .sink { [weak self] artist in
                self?.switchToDiscoverTab(for: artist, from: searchCoordinator)
            }
            .store(in: &cancellables)
        
        self.searchCoordinator = searchCoordinator
    }
    
    func bindDiscoverCoordinator() {
        let discoverCoordinator = DiscoverCoordinator(discoverService: discoverSerivce, playerService: playerService, searchService: searchService, musicDetailsService: musicDetailsService, queueManager: queueManager)
        
        discoverCoordinator.onDidTapSignOut
            .sink { [weak self] in
                self?.alert = .signout
                withAnimation {
                    self?.isAlertPresented = true
                }
            }
            .store(in: &cancellables)
        
        discoverCoordinator.onDidTapDiscoverButton
            .sink { [weak self] artist in
                self?.switchToDiscoverTab(for: artist, from: discoverCoordinator)
            }
            .store(in: &cancellables)
        
        self.discoverCoordinator = discoverCoordinator
    }
    
    func getQueueManager() {
        if let queueStateData = UserDefaults.standard.object(forKey: .UserDefaults.queueState) as? Data,
           let queueState = try? JSONDecoder().decode(QueueState.self, from: queueStateData) {
            self.queueManager.setState(with: queueState, playNow: false)
        }
    }
    
    func switchToDiscoverTab<Coordinator: MusicDetailsCoordinatorProtocol>(for artist: Artist, from coordinator: Coordinator) {
        discoverCoordinator?.navigationPath.removeLast(coordinator.navigationPath.count)
        
        withAnimation {
            coordinator.navigationPath.removeLast(coordinator.navigationPath.count)
        }
        
        withAnimation {
            tab = .discover
        }
        
        discoverCoordinator?.discover(with: artist)
    }
}

// MARK: - Alert
extension RootCoordinator {
    @ViewBuilder
    func presentAlertView(isPresented: Binding<Bool>) -> some View {
        switch alert {
        case .signout:
            AlertView(isPresented: isPresented, title: .Profile.signoutTitle, message: .Profile.signoutMessage, primaryActionText: .Profile.signoutTitle) { [weak self] in
                self?.onDidEnd.send()
            }
        }
    }
}
