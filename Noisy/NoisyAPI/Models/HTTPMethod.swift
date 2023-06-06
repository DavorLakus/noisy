//
//  HTTPMethod.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

public enum HTTPMethod {
    case get
    case post
    case put
    case delete
    case patch

    var description: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        case .patch:
            return "PATCH"
        }
    }
}
