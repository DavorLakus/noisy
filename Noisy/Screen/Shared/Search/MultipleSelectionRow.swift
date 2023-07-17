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
                Text(title)
                    .foregroundColor(.gray700)
                    .font(.nunitoRegular(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Toggle(String.empty, isOn: $isSelected)
                    .toggleStyle(.checkList)
                    .disabled(true)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, Constants.spacing)
        }
        .buttonStyle(.plain)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.isOn ? Image.Shared.checkboxFill : Image.Shared.checkbox
        }
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkList: CheckboxToggleStyle { .init() }
}
