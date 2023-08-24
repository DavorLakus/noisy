//
//  HomeView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground
                .circleOverlay(xOffset: -0.5, yOffset: -0.2, frameMultiplier: 1.0, color: .mint600)
                .circleOverlay(xOffset: -0.8, yOffset: 0.8)
            
            bodyView()
            headerView()
        }
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.viewDidAppear)
        .dynamicModalSheet(isPresented: $viewModel.isOptionsSheetPresented) {
            OptionsView(isPresented: $viewModel.isOptionsSheetPresented, options: viewModel.options)
                .toast(isPresented: $viewModel.isToastPresented, message: viewModel.toastMessage)
        }
    }
}

// MARK: - Body components
private extension HomeView {
    func bodyView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.margin) {
                Spacer(minLength: 100)
                recentlyPlayedSection()
                topTracksAccordion()
                topArtistsAccordion()
                playlistsAccordion()
                Spacer(minLength: 80)
            }
            .padding(.vertical, Constants.margin)
        }
        .refreshable(action: viewModel.viewDidAppear)
    }
}

// MARK: - Recently played
extension HomeView {
    func recentlyPlayedSection() -> some View {
        VStack {
            Button {
                withAnimation {
                    viewModel.isRecentlyPlayedSectionExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(String.Home.recentlyPlayed)
                        .foregroundColor(.gray700)
                        .font(.nunitoBold(size: 20))
                    
                    Spacer()
                    
                    Image.Shared.chevronRight
                        .rotationEffect(viewModel.isRecentlyPlayedSectionExpanded ? .degrees(90) : .degrees(0))
                }
                .background { Color.white }
            }
            .buttonStyle(.plain)
            
            if viewModel.isRecentlyPlayedSectionExpanded {
                ForEach(viewModel.recentlyPlayedTracks, id: \.track.id) { historicTrack in
                    historicTrackRow(for: historicTrack)
                        .onTapGesture {
                            viewModel.trackRowSelected(for: historicTrack.track)
                        }
                }
                Button(action: viewModel.loadMoreTapped) {
                    Text(String.Home.loadMore)
                        .font(.nunitoBold(size: 18))
                        .foregroundColor(.purple600)
                }
            }
        }
        .padding(Constants.margin)
        .cardBackground(borderColor: .gray400, hasShadow: false)
        .padding(.horizontal, Constants.margin)
    }
    
    func historicTrackRow(for historicTrack: PlayHistoricObject) -> some View {
        HStack {
            LoadImage(url: URL(string: historicTrack.track.album?.images.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(historicTrack.track.name)
                    .foregroundColor(.gray700)
                    .lineLimit(1)
                    .font(.nunitoBold(size: 16))
                Text(historicTrack.track.artists.first?.name ?? .empty)
                    .foregroundColor(.gray600)
                    .font(.nunitoSemiBold(size: 14))
            }
            Spacer()
            
            Button {
                viewModel.trackOptionsTapped(for: historicTrack.track)
            } label: {
                Image.Shared.threeDots
                    .foregroundColor(.purple900)
            }
        }
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
        ParameterizedAccordionView(isExpanded: $viewModel.isTopArtistsExpanded, count: $viewModel.topArtistsCount, timeRange: $viewModel.topArtistsTimeRange, title: .Home.topArtists, data: viewModel.topArtists.enumerated(), dataRowView: artistRow, action: viewModel.artistRowSelected, optionsAction: nil)
    }
}

// MARK: - Playlists accordion
extension HomeView {
    func playlistsAccordion() -> some View {
        ParameterizedAccordionView(isExpanded: $viewModel.isPlaylistsExpanded, count: $viewModel.playlistsCount, timeRange: nil, title: .Home.playlists, data: viewModel.playlists.enumerated(), dataRowView: playlistRow, action: viewModel.playlistRowSelected, optionsAction: nil)
    }
}

// MARK: - Header view
private extension HomeView {
    func headerView() -> some View {
        HStack {
            Spacer()
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
            .background {
                Circle()
                    .fill(Color.yellow300)
                    .shadow(color: .gray500, radius: 2)
                    .frame(width: 160, height: 160)
                    .offset(x: 20, y: -30)
            }
        }
        .padding(Constants.margin)
        .padding(.top, 40)
    }
    
}
