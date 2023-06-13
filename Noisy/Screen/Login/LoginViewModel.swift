//
//  LoginViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine
import SwiftUI

final class LoginViewModel: ObservableObject {
    // MARK: - Coordinator actions
    let onViewDidAppear = PassthroughSubject<Void, Never>()
    let onDidTapLogin = PassthroughSubject<Void, Never>()
    
    // MARK: - Published properties
    @Published var email: String = .empty
    @Published var presentError = false
    
    // MARK: - Public properties
    var errorMessage: String = .empty
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Class lifecycle
}

// MARK: - Public extensions
extension LoginViewModel {
    func viewDidAppear() {
        
    }
    
    func loginTapped() {
        onDidTapLogin.send()
//        if email.isEmpty {
//            errorMessage = .Login.emptyEmailError
//            presentError = true
//        } else {        }
        
        $email
            .dropFirst()
            .sink { [weak self] _ in
                withAnimation {
                    self?.presentError = false
                }
            }
            .store(in: &cancellables)
    }
}
