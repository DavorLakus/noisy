//
//  Extensions.swift
//  Noisy
//
//  Created by Davor Lakus on 20.07.2023..
//

import AVKit
import Foundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension Formatter {
    static let positional: DateComponentsFormatter = {
        let positional = DateComponentsFormatter()
        positional.unitsStyle = .positional
        positional.zeroFormattingBehavior = .pad
        return positional
    }()
}

extension TimeInterval {
    var positionalTime: String {
        Formatter.positional.allowedUnits = self >= 3600 ?
        [.hour, .minute, .second] :
        [.minute, .second]
        let string = Formatter.positional.string(from: self)!
        return string.hasPrefix("0") && string.count > 4 ?
            .init(string.dropFirst()) : string
    }
}

