//
//  Fonts.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

extension Font {
    static func nunitoRegular(size: CGFloat) -> Font {
        Font.custom("Nunito-Regular", size: size)
    }
    
    static func nunitoSemiBold(size: CGFloat) -> Font {
        Font.custom("Nunito-SemiBold", size: size)
    }
    
    static func nunitoBold(size: CGFloat) -> Font {
        Font.custom("Nunito-Bold", size: size)
    }
}
