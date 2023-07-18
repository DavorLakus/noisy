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
                .font(.nunitoSemiBold(size: 18))
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
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray700)
        }
    }
    
    @ToolbarContentBuilder
    func accountButton<ProfileImage: View>(avatar: ProfileImage, action: @escaping () -> Void) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                action()
            } label: {
                avatar
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
        }
    }
}
