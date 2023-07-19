//
//  PlaylistView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct PlaylistView: View {
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        bodyView()
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body view
extension PlaylistView {
    func bodyView() -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Color.purple100.ignoresSafeArea(edges: [.horizontal, .top])
            VStack {
                Text("Playlist")
            }
            .padding(Constants.margin)
        }
        
    }
}

// MARK: - Toolbar
extension PlaylistView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingToolbarButton()
        centeredTitle("Playlist name")
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
