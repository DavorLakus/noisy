//
//  QueueView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct QueueView: View {
    @ObservedObject var viewModel: QueueViewModel
    
    var body: some View {
        bodyView()
            .toolbar(content: toolbarContent)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Body
extension QueueView {
    func bodyView() -> some View {
        ZStack {
            Color.green400
                .ignoresSafeArea()
        }
    }
}

// MARK: - Toolbar
extension QueueView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingToolbarButton()
        centeredTitle(.Player.currentQueue)
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
