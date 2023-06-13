//
//  LoginCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine
import SwiftUI

final class LoginCoordinator: ObservableObject {

    // MARK: - Published properties
    @Published var path = NavigationPath()
    @Published var authSheetIsPresented = false
    
    // MARK: - Public properties
    let onDidEnd = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private lazy var loginViewModel = LoginViewModel()
    private var authViewModel: AuthViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Services
    private let loginService: LoginService
    
    // MARK: - Class lifecycle
    init(loginService: LoginService) {
        self.loginService = loginService
        bindLoginViewModel()
    }

    @ViewBuilder
    func loginView() -> some View {
        LoginView(viewModel: self.loginViewModel)
    }
    
    @ViewBuilder
    func authSheet() -> some View {
        if let authViewModel {
            AuthView(viewModel: authViewModel)
        }
    }
}

// MARK: - Binding
extension LoginCoordinator {
    func bindLoginViewModel() {
        loginViewModel.onDidTapLogin
            .sink { [weak self] in
                self?.bindAuthViewModel()
            }
            .store(in: &cancellables)
    }
    
    func bindAuthViewModel() {
        authViewModel = AuthViewModel(loginService: loginService)
        
        authViewModel?.onDidAuthorize
            .sink { [weak self] in
                withAnimation {
                    self?.authSheetIsPresented = false
                }
                self?.onDidEnd.send()
            }
            .store(in: &cancellables)
        
        withAnimation {
            authSheetIsPresented = true
        }
    }
}

// MARK: - CoordinatorView lifecycle
extension LoginCoordinator {
    func viewDidAppear() {
        //        bindErrorHandling()
    }
    
    func viewDidDisappear() {
//        errorAlertCancellable = nil
    }
}
