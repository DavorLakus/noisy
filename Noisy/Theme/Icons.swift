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
        static let magnifyingGlass = Image(systemName: "magnifyingglass")
        static let checkbox = Image(systemName: "square")
        static let checkboxFill = Image(systemName: "x.square.fill")
        static let filter = Image(systemName: "slider.horizontal.3")
        static let sort = Image(systemName: "arrow.up.arrow.down")
    }
    
    struct Home {
        static let sparkles = Image(systemName: "sparkles")
        static let profile = Image(systemName: "person.circle.fill")
    }
}
