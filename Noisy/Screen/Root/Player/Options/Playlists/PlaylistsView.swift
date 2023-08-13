//
//  PlaylistsView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct PlaylistsView: View {
    @ObservedObject var viewModel: PlaylistsViewModel
    
    var body: some View {
        bodyView()
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body view
extension PlaylistsView {
    func bodyView() -> some View {
        ZStack {
            Color.yellow100.ignoresSafeArea()
            VStack {
                Text("Playlists")
            }
            .padding(Constants.margin)
        }
        
    }
}

// MARK: - Toolbar
extension PlaylistsView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingToolbarButton()
        centeredTitle("Playlists")
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
