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
        static let chevronLeft = Image(systemName: "chevron.left")
        static let chevronDown = Image(systemName: "chevron.down")
        static let chevronRight = Image(systemName: "chevron.right")
        static let magnifyingGlass = Image(systemName: "magnifyingglass")
        static let checkbox = Image(systemName: "square")
        static let checkboxFill = Image(systemName: "dot.square.fill")
        static let filter = Image(systemName: "slider.horizontal.3")
        static let sort = Image(systemName: "arrow.up.arrow.down")
        static let albumPlaceholder: Image = Image("albumPlaceholder")
        static let plusCircle: Image = Image(systemName: "plus.circle")
    }
    
    struct Search {
        static let arrowUp: Image = Image(systemName: "water.waves.and.arrow.up")
    }
    
    struct Home {
        static let sparkles = Image(systemName: "sparkles")
        static let profile = Image(systemName: "person.circle.fill")
    }
    
    struct Player {
        static let threeDots = Image(systemName: "ellipsis")
        static let play = Image(systemName: "play")
        static let playCircle = Image(systemName: "play.circle")
        static let pause = Image(systemName: "pause")
        static let pauseCircle = Image(systemName: "pause.circle")
        static let plus = Image(systemName: "plus.app")
        static let previous = Image(systemName: "arrowtriangle.left")
        static let next = Image(systemName: "arrowtriangle.right")
        static let queue = Image(systemName: "list.triangle")
        static let share = Image(systemName: "square.and.arrow.up")
    }
}
