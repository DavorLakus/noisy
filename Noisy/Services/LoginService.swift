//
//  LoginService.swift
//  Noisy
//
//  Created by Davor Lakus on 13.06.2023..
//

import Foundation
import Combine

final class LoginService {
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    private let api: NoisyAPIProtocol
    
    // MARK: - Class lifecycle
    public init(api: NoisyAPIProtocol) {
        self.api = api
    }
}

// MARK: - Public extension
extension LoginService {
    func getAuthURL(verifier: String) -> URL {
        api.getAuthURL(verifier: verifier)
    }
    
    func postToken(code: String) -> PassthroughSubject<TokenResponse, Never> {
     let token = PassthroughSubject<TokenResponse, Never>()
        
        if let codeVerifier = UserDefaults.standard.string(forKey: .KeyChain.codeVerifier) {
            
            api.postToken(verifier: codeVerifier, code: code)
                .debugPrint()
                .decode(type: TokenResponse.self, decoder: JSONDecoder())
                .sink(
                    receiveCompletion: NetworkingManager.handleCompletion,
                    receiveValue: { [weak self] response in
                        token.send(response)
                    })
                .store(in: &cancellables)
        }
        
        return token
    }
}
