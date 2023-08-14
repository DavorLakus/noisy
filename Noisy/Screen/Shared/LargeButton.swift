//
//  LargeButton.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import SwiftUI

struct LargeButton: View {
    let foregroundColor: Color
    let backgroundColor: Color
    let padding: CGFloat
    let title: String
    let action: () -> Void
    
    init(foregroundColor: Color, backgroundColor: Color, padding: CGFloat = 16, title: String, action: @escaping () -> Void) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.padding = padding
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(foregroundColor)
                .font(.nunitoBold(size: 17))
                .frame(maxWidth: .infinity)
        }
        .padding(padding)
        .cardBackground(backgroundColor: backgroundColor, borderColor: .gray400, hasShadow: false)
    }
}
