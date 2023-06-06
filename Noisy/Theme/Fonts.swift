//
//  Fonts.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

extension Font {
    static func nutinoRegular(size: CGFloat) -> Font {
        Font.custom("Nunito-Regular", size: size)
    }
    
    static func nutinoSemiBold(size: CGFloat) -> Font {
        Font.custom("Nunito-SemiBold", size: size)
    }
    
    static func nutinoBold(size: CGFloat) -> Font {
        Font.custom("Nunito-Bold", size: size)
    }
}
