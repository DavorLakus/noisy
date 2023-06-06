//
//  NoisyHTTPRouter.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation

public enum NoisyHTTPRouter {
    case base
}

extension NoisyHTTPRouter: APIEndpoint {
    public var path: String {
        switch self {
        case .base:
            return "/employees/team-members"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .base:
            return .get
        }
    }
    
    public var headers: [String : Any]? {
        switch self {
        case .base:
            return nil
        }
    }
    
    public func body() throws -> Data? {
        switch self {
        case .base:
            return nil
        }
    }
    
    public var parameters: [URLQueryItem]? {
        switch self {
        case .base:
            return nil
        }
    }
}
