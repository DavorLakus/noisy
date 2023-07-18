//
//  OptionsView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct OptionsView: View {
    @ObservedObject var viewModel: OptionsViewModel
    
    var body: some View {
        bodyView()
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body view
extension OptionsView {
    func bodyView() -> some View {
        VStack {
            optionRow(icon: .Shared.plusCircle, title: "Add to playlist", action: viewModel.addToPlaylistButtonTapped)
            
            Spacer()
        }
        .padding(Constants.margin)
        
    }
    
    func optionRow(icon: Image, title: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 24) {
            icon
            Text(title)
                .font(.nunitoSemiBold(size: 18))
                .foregroundColor(.gray600)
            Spacer()
        }
        .onTapGesture(perform: action)
    }
}

// MARK: - Toolbar
extension OptionsView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingToolbarButton()
        centeredTitle("Track name")
    }
    
    @ToolbarContentBuilder
    func leadingToolbarButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: viewModel.backButtonTapped) {
                Image.Shared.chevronLeft
                    .foregroundColor(.gray600)
            }
        }
    }
}
