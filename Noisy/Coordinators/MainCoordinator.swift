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
    
    static func isTokenValid() -> Bool {
        if let expirationDateData = UserDefaults.standard.data(forKey: .UserDefaults.tokenExpirationDate),
           let expirationDate = try? JSONDecoder().decode(Date.self, from: expirationDateData),
            expirationDate > .now {
            return true
        }
        return false
    }
}

final class MainCoordinator: CoordinatorProtocol {
    // MARK: - Published properties
    @Published var flow: Flow = .splash
    @Published var isLoading = false
    @Published var isSpotifyAlertPresented = false
    @Published var spotifyError: SpotifyError?
    @Published var state: AppState = .loaded
    
    // MARK: - Private properties
    private lazy var loginSerice = LoginService(api: api)
    private lazy var homeService = HomeService(api: api)
    private lazy var searchService = SearchService(api: api)
    private lazy var discoverSerivce = DiscoverService(api: api)
    private lazy var playerService = PlayerService(api: api)
    private lazy var musicDetailsService = MusicDetailsService(api: api)
    private lazy var api: NoisyAPIProtocol = NoisyService()
    
    private var loginCoordinator: LoginCoordinator?
    private var rootCoordinator: RootCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    private var badResponseCancellable: AnyCancellable?
    
    // MARK: - Class lifecycle
    init() {
        bindAppState()
        bindFlow()
    }
    
    @ViewBuilder
    func start() -> some View {
        MainCoordinatorView(coordinator: self)
    }
    
    func bindFlow() {
        $flow.sink { [weak self] flow in
            switch flow {
            case .splash:
                break
            case .login:
                self?.bindLoginCoordinator()
            case .home:
                self?.bindRootCoordinator()
            }
        }
        .store(in: &cancellables)
    }
}

// MARK: - App state
extension MainCoordinator {
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
                UserDefaults.standard.set(nil, forKey: .UserDefaults.tokenExpirationDate)
                withAnimation {
                    self?.flow = .login()
                }
            }
            .store(in: &cancellables)
        
        NetworkingManager.showSpotifyError
            .sink { [weak self] error in
                withAnimation {
                    self?.spotifyError = error
                    self?.isSpotifyAlertPresented = true
                }
            }
            .store(in: &cancellables)
    }
    
    func setupFlow() {
        if Flow.isTokenValid() {
            flow = Flow.isAuthorized()
        } else {
            attemptRefreshToken()
        }
    }
    
    func attemptRefreshToken() {
        if let refreshToken = UserDefaults.standard.string(forKey: .UserDefaults.refreshToken) {
            loginSerice.refreshToken(with: refreshToken)
                .sink { [weak self] response in
                    UserDefaults.standard.set(response.accessToken, forKey: .UserDefaults.accessToken)
                    UserDefaults.standard.set(response.refreshToken, forKey: .UserDefaults.refreshToken)
                    let expirationDate = Date.now.advanced(by: Double(response.expiresIn) - 60)
                    if let expirateionDateData = try? JSONEncoder().encode(expirationDate) {
                        UserDefaults.standard.set(expirateionDateData, forKey: .UserDefaults.tokenExpirationDate)
                    }

                    withAnimation {
                        self?.rootCoordinator?.tokenDidRefresh.send()
                        self?.setupFlow()
                    }
                }
                .store(in: &cancellables)
        } else {
            withAnimation {
                flow = .login()
            }
        }
    }
}

// MARK: - Flows
extension MainCoordinator {
    func showSplashView() -> some View {
        let viewModel = SplashViewModel()
        let view = SplashView(viewModel: viewModel)

        viewModel.onSplashAnimationDidEnd
            .sink { [weak self] in
                self?.setupFlow()
            }
            .store(in: &cancellables)

        return view
    }
    
    @ViewBuilder
    func presentLoginFlow() -> some View {
        loginCoordinator?.start()
    }
    
    @ViewBuilder
    func presentRootFlow() -> some View {
        rootCoordinator?.start()
    }
}

// MARK: - Coordinator binding
extension MainCoordinator {
    func bindLoginCoordinator() {
        loginCoordinator = LoginCoordinator(loginService: loginSerice)
        
        loginCoordinator?.onDidEnd
            .sink { [weak self] in
                self?.flow = .home()
            }
            .store(in: &cancellables)
    }
    
    func bindRootCoordinator() {
        rootCoordinator = RootCoordinator(homeService: homeService, searchService: searchService, discoverService: discoverSerivce, playerService: playerService, musicDetailsService: musicDetailsService)
        
        rootCoordinator?.onDidEnd
            .sink { [weak self] in
                UserDefaults.standard.set(nil, forKey: .UserDefaults.accessToken)
                UserDefaults.standard.set(nil, forKey: .UserDefaults.refreshToken)
                UserDefaults.standard.set(nil, forKey: .UserDefaults.tokenExpirationDate)
                self?.flow = .login()
            }
            .store(in: &cancellables)
    }
}
