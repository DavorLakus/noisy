//
//  NoisyService.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation
import Combine

public protocol NoisyAPIProtocol {
    func getAuthURL(verifier: String) -> URL
    func postToken(verifier: String, code: String) -> AnyPublisher<Data, Error>
    func getProfile() -> AnyPublisher<Data, Error>
}

public final class NoisyService: NoisyAPIProtocol {
    
    // MARK: - Class lifecycle
    public init() { }
}

// MARK: - functions
extension NoisyService {
    public func getAuthURL(verifier: String) -> URL {
        NoisyHTTPRouter.authorize(NoisyCrypto.generateCodeChallenge(randomString: verifier)).url
    }
    
    public func postToken(verifier: String, code: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.token(verifier, code))
    }
    
    public func getProfile() -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.profile)
    }
}

import CryptoKit

public final class NoisyCrypto {
    static func generateRandomString(length: Int = Int.random(in: (43...128))) -> String {
        var text = ""
        let possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        (0...length).forEach { _ in
            if let randomChar = possible.randomElement() {
                text += String(randomChar)
            }
        }
        
        return text
      }
    
    static func generateCodeChallenge(randomString: String) -> String {
        func base64encode(data: Data) -> String {
            return data.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
        }

        guard let codeVerifierData = randomString.data(using: .utf8) else {
            return .empty
        }
        
        let sha256Digest = SHA256.hash(data: codeVerifierData)
        let digestData = Data(sha256Digest)
        
        return base64encode(data: digestData)
    }
}
