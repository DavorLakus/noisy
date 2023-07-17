//
//  SingleSelectionRow.swift
//  Noisy
//
//  Created by Davor Lakus on 17.07.2023..
//

import SwiftUI

struct SingleSelectionRow: View {
    @Binding var isSelected: Bool

    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .purple100 : .gray700)
                    .font(isSelected ? .nunitoSemiBold(size: 16) : .nunitoRegular(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Image.Shared.checkbox
                        .foregroundColor(.purple100)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, Constants.spacing)
            .background(Color.appBackground)
        }
        .buttonStyle(.plain)
    }
}
