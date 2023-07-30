//
//  SeedCard.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import SwiftUI

struct SeedCard: View {
    let title: String
    let id: String
    let background: Color
    let action: (String) -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray700)
            Image.Shared.close
                .onTapGesture {
                    action(id)
                }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .cardBackground(backgroundColor: background, borderColor: .gray700)
    }
}
