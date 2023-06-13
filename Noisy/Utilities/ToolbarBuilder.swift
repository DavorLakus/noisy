//
//  ToolbarBuilder.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

extension View {
    @ToolbarContentBuilder
    func leadingLargeTitle(title: String) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Text(title)
                .foregroundColor(.gray700)
                .font(.nutinoSemiBold(size: 18))
        }
    }

    @ToolbarContentBuilder
    func backButton(action: @escaping () -> Void) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: action) {
                Image.Tabs.discover
                    .foregroundColor(.gray700)
            }
        }
    }

    @ToolbarContentBuilder
    func centeredTitle(_ title: String) -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.nutinoSemiBold(size: 14))
                .foregroundColor(.gray700)
        }
    }
}

