//
//  OptionsView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

enum OptionRow: Identifiable {
    case addToQueue(track: String, action: (String) -> Void)
    
    var icon: Image {
        switch self {
        case .addToQueue:
            return Image.Shared.addToQueue
        }
    }
    
    var title: String {
        switch self {
        case .addToQueue:
            return .Shared.addToQueue
        }
    }
    
    var id: String {
        String(describing: self)
    }
}

struct OptionsView: View {
    let options: [OptionRow]
    let dismiss: () -> Void
    
    var body: some View {
        bodyView()
    }
}

// MARK: - Body view
extension OptionsView {
    func bodyView() -> some View {
        VStack(alignment: .trailing) {
            Button(action: dismiss) {
                Text(String.Shared.done)
                    .foregroundColor(.green500)
                    .font(.nunitoBold(size: 18))
            }
            ScrollView {
                LazyVStack {
                    ForEach(options) { option in
                        optionRow(for: option)
                    }
                }
                .padding(Constants.margin)
            }
        }
        
    }
    
    func optionRow(for optionRow: OptionRow) -> some View {
        Button {
            switch optionRow {
            case .addToQueue(let track, let action):
                action(track)
            }
        } label: {
            HStack(spacing: 24) {
                optionRow.icon
                Text(optionRow.title)
                    .font(.nunitoSemiBold(size: 18))
                    .foregroundColor(.gray600)
                Spacer()
            }
        }
    }
}
