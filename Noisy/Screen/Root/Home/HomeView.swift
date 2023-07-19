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
            VStack(alignment: .leading, spacing: .zero) {
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
        ParameterizedAccordionView(isExpanded: $viewModel.isTopTracksExpanded, count: $viewModel.topTracksCount, timeRange: $viewModel.topTracksTimeRange, title: .Home.topTracks, data: viewModel.topTracks.enumerated(), dataRowView: trackRow, action: viewModel.trackRowSelected)
    }
    
    func trackRow(for track: EnumeratedSequence<[Track]>.Iterator.Element) -> some View {
        HStack(spacing: Constants.margin) {
            Text("\(track.offset + 1)")
                .foregroundColor(.gray500)
                .font(.nunitoRegular(size: 14))
            
            LoadImage(url: URL(string: track.element.album.images.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(track.element.artists.first?.name ?? .empty)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text(track.element.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoSemiBold(size: 14))
                    .frame(maxHeight: .infinity)
                
            }
            Spacer()
        }
        .onTapGesture { viewModel.trackRowSelected(for: track.element) }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

// MARK: - Artists accordion
extension HomeView {
    func topArtistsAccordion() -> some View {
        ParameterizedAccordionView(isExpanded: $viewModel.isTopArtistsExpanded, count: $viewModel.topArtistsCount, timeRange: $viewModel.topArtistsTimeRange, title: .Home.topArtists, data: viewModel.topArtists.enumerated(), dataRowView: artistRow, action: viewModel.artistRowSelected)
    }
}

// MARK: - Playlists accordion
extension HomeView {
    func playlistsAccordion() -> some View {
        ParameterizedAccordionView(isExpanded: $viewModel.isPlaylistsExpanded, count: $viewModel.playlistsCount, timeRange: nil, title: .Home.playlists, data: viewModel.playlists.enumerated(), dataRowView: playlistRow, action: viewModel.playlistRowSelected)
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
