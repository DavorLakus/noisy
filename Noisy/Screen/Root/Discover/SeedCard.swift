//
//  SeedCard.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import SwiftUI

struct SeedCard: View {
    let model: SeedCardModel
    let cropTitle: Bool
    
    var body: some View {
        HStack {
            Text(model.title)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray700)
                .lineLimit(cropTitle ? 1 : 0)
            if let subtitle = model.subtitle {
                Text(subtitle)
                    .font(.nunitoSemiBold(size: 14))
                    .foregroundColor(.gray600)
                    .lineLimit(cropTitle ? 1 : 0)
            }
            Image.Shared.close
                .onTapGesture {
                    model.action(model.id)
                }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .cardBackground(backgroundColor: model.background, borderColor: .gray700, hasShadow: false)
    }
}
