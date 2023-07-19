//
//  AlbumView.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import SwiftUI

struct AlbumView: View {
    @ObservedObject var viewModel: AlbumViewModel
    
    var body: some View {
        bodyView()
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body view
extension AlbumView {
    func bodyView() -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Color.purple100.ignoresSafeArea(edges: [.horizontal, .top])
            VStack {
                Text("Album")
            }
            .padding(Constants.margin)
        }
        
    }
}

// MARK: - Toolbar
extension AlbumView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingToolbarButton()
        centeredTitle("Album name")
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
