//
//  NetworkError.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation

enum NetworkError: LocalizedError {
    case badURLResponse(router: NoisyHTTPRouter, statusCode: Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case let .badURLResponse(router, _):
            return "Bad response from URL: \(router.path)"
        case .unknown:
            return "Unknown error occured"
        }
    }
}

