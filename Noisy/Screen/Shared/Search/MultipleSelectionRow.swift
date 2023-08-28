//
//  MultipleSelectionRow.swift
//  Noisy
//
//  Created by Davor Lakus on 17.07.2023..
//

import SwiftUI

struct MultipleSelectionRow: View {
    @Binding var isSelected: Bool

    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title.capitalized(with: .current))
                    .foregroundColor(.gray700)
                    .font(.nunitoSemiBold(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)

                (isSelected ? Image.Shared.checkboxFill : Image.Shared.checkbox)
                    .resizable()
                    .foregroundColor(.purple600)
                    .frame(width: 16, height: 16)
                    .animation(.none, value: isSelected)
            }
            .padding(.vertical, Constants.spacing)
            .padding(.horizontal, 30)
            .background {
                Color.appBackground
                    .opacity(0.35)
                    .blur(radius: 4)
                    .mask(Capsule())
            }
            .padding(.horizontal, 18)
        }
        .buttonStyle(.plain)
    }
}
