//
//  ArtistView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct ArtistView: View {
    @ObservedObject var viewModel: ArtistViewModel
    
    var body: some View {
        bodyView()
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body view
extension ArtistView {
    func bodyView() -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                headerView()
                mostPlayedFrom()
            }
            .ignoresSafeArea()
        }
    }
    
    func headerView() -> some View {
        ZStack(alignment: .bottomLeading) {
            LoadImage(url: URL(string: viewModel.artist.images?.first?.url ?? .empty))
                .scaledToFit()
            LinearGradient(colors: [.clear, .clear, .clear, .gray600], startPoint: .top, endPoint: .bottom)
            Text(viewModel.artist.name)
                .font(.nunitoBold(size: 36))
                .padding(32)
                .foregroundColor(.white)
        }
    }
    
    func mostPlayedFrom() -> some View {
        SimpleAccordionView(isExpanded: $viewModel.isMostPlayedExpanded, title: "\(viewModel.artist.name) \(String.Artist.mostPlayed)", data: viewModel.topTracks.enumerated(), dataRowView: trackRow, action: viewModel.trackRowTapped)
    }
    
//    func albums() -> some View {
//
//    }
}

// MARK: - Toolbar
extension ArtistView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingToolbarButton()
        centeredTitle("Artist name")
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
