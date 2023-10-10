//
//  AuthViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 13.06.2023..
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    
    // MARK: - Published properties
    @Published var link: URL
    
    // MARK: - Public properties
    let onDidAuthorize = PassthroughSubject<Void, Never>()
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private let loginService: LoginService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(loginService: LoginService) {
        let codeVerifier = NoisyCrypto.generateRandomString(length: 127)
        UserDefaults.standard.set(codeVerifier, forKey: .UserDefaults.codeVerifier)
        self.link = loginService.getAuthURL(verifier: codeVerifier)
        self.loginService = loginService
    }
}

// MARK: - Public extensions
extension AuthViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func codeReceived(_ code: String) {
        loginService.postToken(code: code)
            .sink { [weak self ] token in
                UserDefaults.standard.set(token.refreshToken, forKey: .UserDefaults.refreshToken)
                UserDefaults.standard.set(token.accessToken, forKey: .UserDefaults.accessToken)
                let expirationDate = Date.now.advanced(by: Double(token.expiresIn) - 60)
                if let expirateionDateData = try? JSONEncoder().encode(expirationDate) {
                    UserDefaults.standard.set(expirateionDateData, forKey: .UserDefaults.tokenExpirationDate)
                }
                self?.onDidAuthorize.send()
            }
            .store(in: &cancellables)
    }
}
