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
    @Published var presentAlert = false
    @Published var presentAccountDrawer = false
    @Published var alert: Alert = .signout
    
    // MARK: - Public properties
    let onDidEnd = PassthroughSubject<Void, Never>()
    
    // MARK: - Services
    private let homeService: HomeService
    
    // MARK: - Coordinators
    private lazy var homeCoordinator = HomeCoordinator(homeService: homeService)
    
    // MARK: - Private properties
    private var accountViewModel: AccountViewModel?
    private var alertViewModel: AlertViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(homeService: HomeService) {
        self.homeService = homeService
    }
    
    func start() -> some View {
        RootCoordinatorView(coordinator: self)
    }
    
}

// MARK: - Tabs
extension RootCoordinator {

    // Grafika muzike, statistike, itd.
    func homeTab() -> some View {
        HomeCoordinatorView(coordinator: homeCoordinator)
    }
    
    func discoverTab() -> some View {
        Color.green400
    }
    
    func searchTab() -> some View {
        Color.green500
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

// MARK: - Account
extension RootCoordinator {
    @ViewBuilder
    func presentAccountView() -> some View {
        if let accountViewModel {
            AccountView(viewModel: accountViewModel)
        }
    }
    
    func bindAccountViewModel() {
        let accountViewModel = AccountViewModel()
        
        accountViewModel.onDidTapBackButton
            .sink { [weak self] in
                withAnimation {
                    self?.presentAccountDrawer = false
                    self?.accountViewModel = nil
                }
            }
            .store(in: &cancellables)
        
        accountViewModel.onDidTapProfileView
            .flatMap({ [weak self] in
                self?.accountViewModel?.viewWillDisappear(isPushNavigation: true)
                return Just($0)
            })
            .debounce(for: .seconds(0.02), scheduler: DispatchQueue.main)
            .sink { [weak self] in
//                self?.profileButtonTapped()
            }
            .store(in: &cancellables)
        
        accountViewModel.onDidTapSignOut
            .sink { [weak self] in
                self?.alert = .signout
                withAnimation {
                    self?.bindAlertViewModel()
                }
            }
            .store(in: &cancellables)
        
        self.accountViewModel = accountViewModel
        withAnimation {
            self.presentAccountDrawer = true
        }
    }
    
    func bindAlertViewModel() {
        alertViewModel = AlertViewModel(isPresented: _presentAlert)

        alertViewModel?.onViewDidAppear
            .sink { [weak self] in
                guard let self else { return }
                switch self.alert {
                case .signout:
                    self.alertViewModel?.onDidTapPrimaryAction = self.onDidEnd
                }
            }
            .store(in: &cancellables)
        
        withAnimation {
            self.presentAlert = true
        }
    }
}
