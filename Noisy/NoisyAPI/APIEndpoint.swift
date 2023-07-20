//
//  APIEndpoint.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation

public protocol APIEndpoint {
    var baseURL: String { get }
    var basePath: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: Any]? { get }
    var parameters: [URLQueryItem]? { get }
    var authToken: [String : Any]? { get }
}

extension APIEndpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseURL
        components.path = basePath + path
        components.queryItems = parameters
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        
        return url
    }

    var request: URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = method.description

        headers?.forEach { (key, value) in
            request.addValue(value as! String, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    public var authToken: [String : Any]? {
        if let token = UserDefaults.standard.string(forKey: .UserDefaults.accessToken) {
            return ["Authorization" : "Bearer \(token)"]
        } else {
            return nil
        }
    }
}
