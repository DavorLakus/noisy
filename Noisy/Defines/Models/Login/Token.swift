//
//  Token.swift
//  Noisy
//
//  Created by Davor Lakus on 13.06.2023..
//

import Foundation

struct TokenResponse: Codable {
    let refreshToken: String
    let tokenType: String
    let accessToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}
