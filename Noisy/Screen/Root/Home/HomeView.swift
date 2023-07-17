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
                            .font(.nunitoBold(size: 24))
                            .padding(Constants.margin)
                    }
                    
                    topTracksAccordion()
                    topArtistsAccordion()
                }
            }
            .refreshable(action: viewModel.viewDidAppear)
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
                        .font(.nunitoBold(size: 20))
                    
                    Spacer()
                    
                    if viewModel.isTopTracksExpanded {
                        Image.Shared.chevronDown
                    } else {
                        Image.Shared.chevronRight
                    }
                }
            }
            .buttonStyle(.plain)
            
            if viewModel.isTopTracksExpanded {
                HStack {
                    Text(String.Home.pickerTitle)
                        .font(.nunitoRegular(size: 14))
                    Picker(String.Home.pickerTitle, selection: $viewModel.topTracksTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) {
                            Text($0.displayName)
                                .font(.nunitoRegular(size: 14))
                        }
                    }
                }
                HStack(spacing: Constants.smallSpacing) {
                    Text(String.Home.sliderCount)
                        .font(.nunitoRegular(size: 14))
                    Text("1")
                        .font(.nunitoRegular(size: 12))
                        .foregroundColor(.gray500)
                    Slider(value: $viewModel.topTracksCount, in: 1...50)
                    Text("50")
                        .font(.nunitoRegular(size: 12))
                        .foregroundColor(.gray500)
                }
                ForEach(Array(viewModel.topTracks.enumerated()), id: \.offset, content: trackRow)
            }
        }
        .padding(Constants.margin)
        .cardBackground()
        .padding(Constants.margin)
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
                        .font(.nunitoBold(size: 20))
                    
                    Spacer()
                    
                    if viewModel.isTopArtistsExpanded {
                        Image.Shared.chevronDown
                    } else {
                        Image.Shared.chevronRight
                    }
                }
            }
            .buttonStyle(.plain)
            
            if viewModel.isTopArtistsExpanded {
                HStack {
                    Text(String.Home.pickerTitle)
                        .font(.nunitoRegular(size: 14))
                    Picker(String.Home.pickerTitle, selection: $viewModel.topArtistsTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) {
                            Text($0.displayName)
                                .font(.nunitoRegular(size: 14))
                        }
                    }
                }
                HStack(spacing: Constants.smallSpacing) {
                    Text(String.Home.sliderCount)
                        .font(.nunitoRegular(size: 14))
                    Text("1")
                        .font(.nunitoRegular(size: 12))
                        .foregroundColor(.gray500)
                    Slider(value: $viewModel.topArtistsCount, in: 1...50)
                    Text("50")
                        .font(.nunitoRegular(size: 12))
                        .foregroundColor(.gray500)
                }
                
                ForEach(Array(viewModel.topArtists.enumerated()), id: \.offset, content: artistRow)
            }
        }
        .padding(Constants.margin)
        .cardBackground()
        .padding(Constants.margin)
    }
    
    func artistRow(for artist: EnumeratedSequence<[Artist]>.Iterator.Element) -> some View {
        HStack(spacing: Constants.margin) {
            Text("\(artist.offset + 1)")
                .foregroundColor(.gray500)
                .font(.nunitoRegular(size: 14))
            LoadImage(url: URL(string: artist.element.images?.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
            Text(artist.element.name)
                .foregroundColor(.gray700)
                .font(.nunitoBold(size: 16))
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
