//
//  MainCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI
import Combine

enum Flow: Equatable {
    case splash
    case login(fromSplash: Bool = false)
    case home(fromSplash: Bool = false)
    
    static func isAuthorized() -> Self {
        UserDefaults.standard.string(forKey: .KeyChain.accessToken) != nil ? .home() : .login()
    }
}

final class MainCoordinator: ObservableObject {
    // MARK: - Published properties
    @Published var flow: Flow = .splash
    @Published var isLoading = false
    @Published var state: AppState = .loaded

    // MARK: - Private properties
    private lazy var loginSerice = LoginService(api: api)
    private lazy var homeService = HomeService(api: api)
    private lazy var api: NoisyAPIProtocol = NoisyService()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Class lifecycle
    init() {
        bindAppState()
    }
    
    func bindAppState() {
        NetworkingManager.state
            .sink { [weak self] state in
                self?.isLoading = state == .loading
            }
            .store(in: &cancellables)
    }

    func showSplashView() -> some View {
        let viewModel = SplashViewModel()
        let view = SplashView(viewModel: viewModel)

        viewModel.onSplashAnimationDidEnd
            .sink { [weak self] in
                self?.flow = Flow.isAuthorized()
            }
            .store(in: &cancellables)

        return view
    }
    
    func presentRootFlow() -> some View {
        let coordinator = RootCoordinator(homeService: homeService)
        
        coordinator.onDidEnd
            .sink { [weak self] in
                self?.flow = .login()
            }
            .store(in: &cancellables)
        
        return RootCoordinatorView(coordinator: coordinator)
    }

    func presentLoginFlow() -> some View {
        let coordinator = LoginCoordinator(loginService: loginSerice)
        
        coordinator.onDidEnd
            .sink { [weak self] in
                self?.flow = .home()
            }
            .store(in: &cancellables)
        
        return LoginCoordinatorView(coordinator: coordinator)
    }
}
