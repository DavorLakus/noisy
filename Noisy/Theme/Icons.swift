//
//  Icons.swift
//  Noisy
//
//  Created by Davor Lakus on 06.06.2023..
//

import SwiftUI

extension Image {
    static let albumPlaceholder: Image = Image("cover").renderingMode(.original)

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
        static let sunDust = Image(systemName: "sun.dust")
        static let sunDustFill = Image(systemName: "sun.dust.fill")
        static let sunHaze = Image(systemName: "sun.haze")
        static let sunHazeFill = Image(systemName: "sun.haze.fill")
        static let plusCircle: Image = Image(systemName: "plus.circle")
        static let info: Image = Image(systemName: "info.circle")
        static let threeDots = Image(systemName: "ellipsis")
        static let addToQueue = Image(systemName: "text.badge.plus")
        static let artist = Image(systemName: "person.crop.circle.dashed")
        static let album = Image(systemName: "play.square.stack")
    }
    
    struct Search {
        static let arrowUp: Image = Image(systemName: "water.waves.and.arrow.up")
    }
    
    struct Home {
        static let sparkles = Image(systemName: "sparkles")
        static let profile = Image(systemName: "person.circle.fill")
    }
    
    struct Player {
        static let play = Image(systemName: "play")
        static let playFill = Image(systemName: "play.fill")
        static let playCircle = Image(systemName: "play.circle")
        static let pause = Image(systemName: "pause")
        static let pauseCircle = Image(systemName: "pause.circle")
        static let plus = Image(systemName: "plus.app")
        static let checkmarkFill: Image = Image(systemName: "checkmark.square.fill")
        static let previous = Image(systemName: "arrowtriangle.left")
        static let next = Image(systemName: "arrowtriangle.right")
        static let queue = Image(systemName: "list.triangle")
        static let share = Image(systemName: "square.and.arrow.up")
    }
}
