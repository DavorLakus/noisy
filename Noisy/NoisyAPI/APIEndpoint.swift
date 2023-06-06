//
//  APIEndpoint.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: Any]? { get }
    var parameters: [URLQueryItem]? { get }

    func body() throws -> Data?
}

extension APIEndpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = APIConstants.scheme
        components.host = APIConstants.host
        components.port = APIConstants.port
        components.path = APIConstants.basePath + path
        components.queryItems = parameters
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }

        return url
    }

    var request: URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = method.description

        request.httpBody = try? body()
        
        headers?.forEach { (key, value) in
            request.addValue(value as! String, forHTTPHeaderField: key)
        }
        
        return request
    }
}
