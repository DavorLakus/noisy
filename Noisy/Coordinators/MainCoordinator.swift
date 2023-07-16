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

final class MainCoordinator: CoordinatorProtocol {
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
    
    @ViewBuilder
    func start() -> some View {
        MainCoordinatorView(coordinator: self)
    }
    
    func bindAppState() {
        NetworkingManager.state
            .sink { [weak self] state in
                self?.isLoading = state == .loading
            }
            .store(in: &cancellables)
        
        NetworkingManager.unauthorizedAccess
            .sink { [weak self] in
                UserDefaults.standard.set(nil, forKey: .KeyChain.accessToken)
                self?.attemptRefreshToken()
            }
            .store(in: &cancellables)
    }
    
    func attemptRefreshToken() {
        if let refreshToken = UserDefaults.standard.string(forKey: .KeyChain.refreshToken) {
            loginSerice.refreshToken(with: refreshToken)
                .sink { [weak self] response in
                    UserDefaults.standard.set(response.accessToken, forKey: .KeyChain.accessToken)
                    withAnimation {
                        self?.flow = .home()
                    }
                }
                .store(in: &cancellables)
        } else {
            withAnimation {
                flow = .login()
            }
        }
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
        
        return coordinator.start()
    }

    func presentLoginFlow() -> some View {
        let coordinator = LoginCoordinator(loginService: loginSerice)
        
        coordinator.onDidEnd
            .sink { [weak self] in
                self?.flow = .home()
            }
            .store(in: &cancellables)
        
        return coordinator.start()
    }
}
