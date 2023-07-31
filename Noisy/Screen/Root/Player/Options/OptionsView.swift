//
//  OptionsView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

enum OptionRow: Identifiable {
    case addToQueue(action: PassthroughSubject<Void, Never>)
    
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
    @Binding var isPresented: Bool
    let options: [OptionRow]
    
    var body: some View {
        bodyView()
    }
}

// MARK: - Body view
extension OptionsView {
    func bodyView() -> some View {
        VStack(alignment: .trailing) {
            Button {
                withAnimation {
                    isPresented = false
                }
            } label: {
                Text(String.Shared.done)
                    .foregroundColor(.green500)
                    .font(.nunitoBold(size: 18))
            }
            .padding(Constants.margin)
            
            VStack {
                ForEach(options) { option in
                    optionRow(for: option)
                }
            }
            .padding(Constants.margin)
            .padding(.bottom, 50)
        }
        
    }
    
    func optionRow(for optionRow: OptionRow) -> some View {
        Button {
            switch optionRow {
            case .addToQueue(let action):
                action.send()
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
