//
//  NoisyHTTPRouter.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation

public enum NoisyHTTPRouter {
    case authorize(String)
    case token(String, String)
    case refreshToken(String)
    case profile
}

extension NoisyHTTPRouter: APIEndpoint {
    public var baseURL: String {
        switch self {
        case .authorize, .token, .refreshToken:
            return "accounts.spotify.com"
        case .profile:
            return "api.spotify.com"
        }
    }
    
    public var basePath: String {
        switch self {
        case .authorize:
            return .empty
        case .token, .refreshToken:
            return "/api"
        case .profile:
            return "/v1"
        }
    }
    
    public var path: String {
        switch self {
        case .authorize:
            return "/authorize"
        case .profile:
            return "/me"
        case .token, .refreshToken:
            return "/token"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .profile, .authorize:
            return .get
        case .token, .refreshToken:
            return .post
        }
    }
    
    public var headers: [String : Any]? {
        switch self {
        case .authorize:
            return nil
        case .profile:
            if let token = UserDefaults.standard.string(forKey: .KeyChain.accessToken) {
                return ["Authorization" : "Bearer \(token)"]
            } else {
                return nil
            }
        case .token, .refreshToken:
            return ["Content-Type" : "application/x-www-form-urlencoded"]
        }
    }
    
    public func body() throws -> Data? {
        switch self {
        case .profile, .authorize, .token, .refreshToken:
            return nil
        }
    }
    
    public var parameters: [URLQueryItem]? {
        switch self {
        case .authorize(let challenge):
            return [
                URLQueryItem(name:"response_type", value: "code"),
                URLQueryItem(name:"client_id", value: APIConstants.clientID),
                URLQueryItem(name:"redirect_uri", value: "https://github.com/DavorLakus/noisy"),
                URLQueryItem(name:"code_challenge_method", value: "S256"),
                URLQueryItem(name:"code_challenge", value: challenge)
            ]
        case .profile:
            return nil
        case .token(let verifier, let code):
            return [
                URLQueryItem(name:"grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name:"redirect_uri", value: "https://github.com/DavorLakus/noisy"),
                URLQueryItem(name:"client_id", value: APIConstants.clientID),
                URLQueryItem(name:"code_verifier", value: verifier)
            ]
        case .refreshToken(let refreshToken):
            return [
                URLQueryItem(name:"grant_type", value: "refresh_token"),
                URLQueryItem(name:"refresh_token", value: refreshToken),
                URLQueryItem(name:"client_id", value: APIConstants.clientID)
            ]
        }
    }
}
