//
//  Icons.swift
//  Noisy
//
//  Created by Davor Lakus on 06.06.2023..
//

import SwiftUI

extension Image {
    struct Tabs {
        static let home = Image(systemName: "house.fill")
        static let discover = Image(systemName: "lightbulb.circle.fill")
        static let search = Image(systemName: "sparkle.magnifyingglass")
        static let liveMusic = Image(systemName: "music.mic.circle.fill")
        static let radio = Image(systemName: "radio.fill")
        static let settings = Image(systemName: "gear.circle.fill")
    }
    
    struct Shared {
        static let close = Image(systemName: "xmark")
        static let chevronRight = Image(systemName: "chevron.right")
        static let chevronDown = Image(systemName: "chevron.down")
    }
    
    struct Home {
        static let sparkles = Image(systemName: "sparkles")
        static let profile = Image(systemName: "person.circle.fill")
    }
}
