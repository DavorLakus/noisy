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
    @Environment(\.colorScheme) var appearance
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()
            Color.appBackground
            navigationBarBottomBorder()
            
            ScrollView {
                VStack(alignment: .leading, spacing: .zero) {
                    if let name = viewModel.profile?.displayName {
                        Text("Welcome \(name)")
                            .foregroundColor(.gray900)
                            .font(.nutinoBold(size: 24))
                            .padding(Constants.margin)
                    }
                    
                    topTracksAccordion()
                    topArtistsAccordion()
                }
            }
        }
        .onAppear(perform: viewModel.viewDidAppear)
        .toolbar {
            leadingLargeTitle(title: String.Tabs.home)
            trailingNavigationBarItem()
        }
    }
}

// MARK: - Body components
private extension HomeView {
    func topTracksAccordion() -> some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            Button {
                viewModel.topTracksTapped()
            } label: {
                HStack {
                    Text(String.Home.topTracks)
                        .padding()
                        .foregroundColor(.gray700)
                        .font(.nutinoBold(size: 20))
                    
                    Spacer()
                    
                    if viewModel.isTopTracksExpanded {
                        Image.Shared.chevronDown
                    } else {
                        Image.Shared.chevronRight
                    }
                }
            }
            
            if viewModel.isTopTracksExpanded {
                HStack {
                    Text(String.Home.pickerTitle)
                        .font(.nutinoRegular(size: 14))
                    Picker(String.Home.pickerTitle, selection: $viewModel.topTracksTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) {
                            Text($0.displayName)
                                .font(.nutinoRegular(size: 14))
                        }
                    }
                }
                HStack(spacing: Constants.smallSpacing) {
                    Text(String.Home.sliderCount)
                        .font(.nutinoRegular(size: 14))
                    Text("1")
                        .font(.nutinoRegular(size: 12))
                        .foregroundColor(.gray500)
                    Slider(value: $viewModel.topTracksCount, in: 1...50)
                    Text("50")
                        .font(.nutinoRegular(size: 12))
                        .foregroundColor(.gray500)
                }
                
                ForEach(viewModel.topTracks, id: \.id, content: trackRow)
            }
        }
        .padding(.horizontal, Constants.margin)
        .cardBackground()
        .padding(Constants.margin)
    }
    
    func trackRow(for track: Track) -> some View {
        HStack(spacing: Constants.margin) {
            LoadImage(url: URL(string: track.album.images.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(track.artists.first?.name ?? .empty)
                    .foregroundColor(.gray700)
                    .font(.nutinoBold(size: 16))
                Text(track.name)
                    .foregroundColor(.gray700)
                    .font(.nutinoSemiBold(size: 14))
                    .frame(maxHeight: .infinity)
                
            }
            Spacer()
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

// MARK: - Artists accordion
extension HomeView {
    func topArtistsAccordion() -> some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            Button {
                viewModel.topArtistsTapped()
            } label: {
                HStack {
                    Text(String.Home.topArtists)
                        .padding()
                        .foregroundColor(.gray700)
                        .font(.nutinoBold(size: 20))
                    
                    Spacer()
                    
                    if viewModel.isTopArtistsExpanded {
                        Image.Shared.chevronDown
                    } else {
                        Image.Shared.chevronRight
                    }
                }
            }
            
            if viewModel.isTopArtistsExpanded {
                HStack {
                    Text(String.Home.pickerTitle)
                        .font(.nutinoRegular(size: 14))
                    Picker(String.Home.pickerTitle, selection: $viewModel.topArtistsTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) {
                            Text($0.displayName)
                                .font(.nutinoRegular(size: 14))
                        }
                    }
                }
                HStack(spacing: Constants.smallSpacing) {
                    Text(String.Home.sliderCount)
                        .font(.nutinoRegular(size: 14))
                    Text("1")
                        .font(.nutinoRegular(size: 12))
                        .foregroundColor(.gray500)
                    Slider(value: $viewModel.topArtistsCount, in: 1...50)
                    Text("50")
                        .font(.nutinoRegular(size: 12))
                        .foregroundColor(.gray500)
                }
                
                ForEach(viewModel.topArtists, id: \.id, content: artistRow)
            }
        }
        .padding(.horizontal, Constants.margin)
        .cardBackground()
        .padding(Constants.margin)
    }
    
    func artistRow(for artist: Artist) -> some View {
        HStack(spacing: Constants.margin) {
            LoadImage(url: URL(string: artist.images?.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
            Text(artist.name)
                .foregroundColor(.gray700)
                .font(.nutinoBold(size: 16))
            Spacer()
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

// MARK: - ToolbarContentBuilder
private extension HomeView {
    @ToolbarContentBuilder
    func trailingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button {
                    viewModel.onNotificationTap()
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
