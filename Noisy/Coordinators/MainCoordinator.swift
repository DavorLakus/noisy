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
        UserDefaults.standard.string(forKey: .UserDefaults.accessToken) != nil ? .home() : .login()
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
    private lazy var searchService = SearchService(api: api)
    private lazy var discoverSerivce = DiscoverService(api: api)
    private lazy var playerService = PlayerService(api: api)
    private lazy var musicDetailsService = MusicDetailsService(api: api)
    private lazy var api: NoisyAPIProtocol = NoisyService()

    private var cancellables = Set<AnyCancellable>()
    private var badResponseCancellable: AnyCancellable?

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
                withAnimation {
                    self?.isLoading = state == .loading
                }
            }
            .store(in: &cancellables)
        
        badResponseCancellable = NetworkingManager.unauthorizedAccess
            .first()
            .sink { [weak self] in
                UserDefaults.standard.set(nil, forKey: .UserDefaults.accessToken)
                self?.attemptRefreshToken()
                self?.badResponseCancellable?.cancel()
            }
        
        NetworkingManager.invalidToken
            .sink { [weak self] in
                print("refresh token no longer valid, logging out")
                UserDefaults.standard.set(nil, forKey: .UserDefaults.accessToken)
                UserDefaults.standard.set(nil, forKey: .UserDefaults.refreshToken)
                withAnimation {
                    self?.flow = .login()
                }
            }
            .store(in: &cancellables)
    }
    
    func attemptRefreshToken() {
        if let refreshToken = UserDefaults.standard.string(forKey: .UserDefaults.refreshToken) {
            loginSerice.refreshToken(with: refreshToken)
                .sink { [weak self] response in
                    UserDefaults.standard.set(response.accessToken, forKey: .UserDefaults.accessToken)
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
        let coordinator = RootCoordinator(homeService: homeService, searchService: searchService, discoverService: discoverSerivce, playerService: playerService, musicDetailsService: musicDetailsService)
        
        coordinator.onDidEnd
            .sink { [weak self] in
                UserDefaults.standard.set(nil, forKey: .UserDefaults.accessToken)
                UserDefaults.standard.set(nil, forKey: .UserDefaults.refreshToken)
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
