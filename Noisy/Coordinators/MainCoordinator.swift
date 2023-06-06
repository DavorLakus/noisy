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
    
    static func isAuthorized(_ isAuthorized: Bool = false) -> Self {
        isAuthorized ? .home() : .login()
    }
}

final class MainCoordinator: ObservableObject {
    // MARK: - Published properties
    @Published var flow: Flow = .splash
    @Published var isLoading = false
    @Published var state: AppState = .loaded

    // MARK: - Private properties

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
        let coordinator = RootCoordinator()
        
        coordinator.onDidEnd
            .sink { [weak self] in
                self?.flow = .login()
            }
            .store(in: &cancellables)
        
        return RootCoordinatorView(coordinator: coordinator)
    }

    func presentLoginFlow() -> some View {
        let viewModel = LoginViewModel()
        let view = LoginView(viewModel: viewModel)
        
        viewModel.onDidTapLogin
            .sink { [weak self] in
                
//                if let user = try? JSONEncoder().encode(user) {
//                    UserDefaults.standard.set(user, forKey: .Login.user)
//                }
                self?.flow = .home()
            }
            .store(in: &cancellables)
        
        NetworkingManager.showError
            .sink { router in
//                if case .login = router {
//                    viewModel.errorMessage = .Login.incorrectEmailError
//                    viewModel.presentError = true
//                }
            }
            .store(in: &cancellables)
        
        return view
    }
}

