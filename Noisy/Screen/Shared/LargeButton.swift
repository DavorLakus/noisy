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
    let title: String
    let action: () -> Void
    
    init(foregroundColor: Color, backgroundColor: Color, title: String, action: @escaping () -> Void) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(foregroundColor)
                .font(.nunitoSemiBold(size: 16))
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .cardBackground(backgroundColor: backgroundColor)
    }
}
