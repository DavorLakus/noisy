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
    
    var url: URL { get }
    var request: URLRequest { get }
    func body() throws -> Data?
}

extension APIEndpoint {
    public var authToken: [String : Any]? {
        if let token = UserDefaults.standard.string(forKey: .UserDefaults.accessToken) {
            return ["Authorization" : "Bearer \(token)"]
        } else {
            return nil
        }
    }
}
