//
//  Colors.swift
//  Noisy
//
//  Created by Davor Lakus on 31.05.2023..
//

import SwiftUI

extension Color {
    static let appBackground = Color("appBackground")
    static let cardBackground = Color("cardBackground")
    static let alertShadow = Color("alertShadow")
    static let cream50 = Color("cream50")
    static let altGray = Color("altGray")
    static let gray50 = Color("gray50")
    static let gray100 = Color("gray100")
    static let gray200 = Color("gray200")
    static let gray300 = Color("gray300")
    static let gray400 = Color("gray400")
    static let gray500 = Color("gray500")
    static let gray600 = Color("gray600")
    static let gray700 = Color("gray700")
    static let gray800 = Color("gray800")
    static let gray900 = Color("gray900")
    static let blue50 = Color("blue50")
    static let blue400 = Color("blue400")
    static let purple100 = Color("purple100")
    static let purple300 = Color("purple300")
    static let purple600 = Color("purple600")
    static let purple900 = Color("purple900")
    static let green200 = Color("green200")
    static let green300 = Color("green300")
    static let green400 = Color("green400")
    static let green500 = Color("green500")
    static let green600 = Color("green600")
    static let green900 = Color("green900")
    static let mint600 = Color("mint600")
    static let orange100 = Color("orange100")
    static let orange400 = Color("orange400")
    static let orange500 = Color("orange500")
    static let red50 = Color("red50")
    static let red200 = Color("red200")
    static let red300 = Color("red300")
    static let red400 = Color("red400")
    static let red500 = Color("red500")
    static let red600 = Color("red600")
    static let yellow100 = Color("yellow100")
    static let yellow200 = Color("yellow200")
    static let yellow300 = Color("yellow300")
    static let yellow400 = Color("yellow400")
}

enum Pastel: CaseIterable {
    case yellow
    case orange
    case purple
    case mint
    
    var color: Color {
        switch self {
        case .yellow:
            return .yellow100
        case .orange:
            return .orange100
        case .purple:
            return .purple900.opacity(0.7)
        case .mint:
            return .mint600
        }
    }
    
    static func randomPastelColors(count: Int) -> [Color] {
        [Color](repeating: .white, count: count)
            .compactMap { _ in
                Pastel.allCases.map {
                    $0.color.opacity(Double.random(in: 0.55...0.9))
                }.randomElement()
            }
    }
}
