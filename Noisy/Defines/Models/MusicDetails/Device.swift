//
//  Device.swift
//  Noisy
//
//  Created by Davor Lakus on 20.08.2023..
//

import Foundation

struct Device: Codable {
          let id: String
          let isActive: Bool
          let name: String
          let type: String
          let volumePercent: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, type
        case isActive = "is_active"
        case volumePercent = "volume_percent"
    }
}
