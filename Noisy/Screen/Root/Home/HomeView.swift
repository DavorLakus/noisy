//
//  HomeView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI
import WebKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()
            
            bodyView()
        }
        .onAppear(perform: viewModel.viewDidAppear)
        .toolbar {
            trailingNavigationBarItem()
        }
    }
}

// MARK: - Body components
private extension HomeView {
    func bodyView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.margin) {
                if let name = viewModel.profile?.displayName {
                    Text("\(String.Home.welcome) \(name)")
                        .foregroundColor(.gray600)
                        .font(.nunitoBold(size: 24))
                        .padding(Constants.margin)
                }
                
                topTracksAccordion()
                topArtistsAccordion()
                playlistsAccordion()
            }
        }
        .refreshable(action: viewModel.viewDidAppear)
    }
}

// MARK: - Tracks accordion
extension HomeView {
    func topTracksAccordion() -> some View {
        ParameterizedAccordionView(isExpanded: $viewModel.isTopTracksExpanded, count: $viewModel.topTracksCount, timeRange: $viewModel.topTracksTimeRange, title: .Home.topTracks, data: viewModel.topTracks.enumerated(), dataRowView: trackRow, action: viewModel.trackRowSelected, optionsAction: viewModel.trackOptionsTapped)
    }
}

// MARK: - Artists accordion
extension HomeView {
    func topArtistsAccordion() -> some View {
        ParameterizedAccordionView(isExpanded: $viewModel.isTopArtistsExpanded, count: $viewModel.topArtistsCount, timeRange: $viewModel.topArtistsTimeRange, title: .Home.topArtists, data: viewModel.topArtists.enumerated(), dataRowView: artistRow, action: viewModel.artistRowSelected, optionsAction: viewModel.artistOptionsTapped)
    }
}

// MARK: - Playlists accordion
extension HomeView {
    func playlistsAccordion() -> some View {
        ParameterizedAccordionView(isExpanded: $viewModel.isPlaylistsExpanded, count: $viewModel.playlistsCount, timeRange: nil, title: .Home.playlists, data: viewModel.playlists.enumerated(), dataRowView: playlistRow, action: viewModel.playlistRowSelected, optionsAction: viewModel.playlistOptionsTapped)
    }
}

// MARK: - ToolbarContentBuilder
private extension HomeView {
    @ToolbarContentBuilder
    func trailingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button {
                    
                } label: {
                    Image.Home.sparkles
                        .foregroundColor(.gray700)
                }
                
                Button {
                    viewModel.profileButtonTapped()
                } label: {
                    AsyncImage(url: URL(string: viewModel.profile?.images.first?.url ?? .empty)) { image in
                        image.resizable()
                    } placeholder: {
                        Image.Home.profile.resizable()
                    }
                    .scaledToFit()
                    .cornerRadius(18)
                    .frame(width: 36, height: 36)
                }
            }
            .padding(8)
        }
    }
}
