//
//  SearchView.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @GestureState var gestureOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 12) {
                SearchBar(isActive: $viewModel.searchIsActive, query: $viewModel.query)
                    .frame(height: 40)
                    .background { Color.appBackground }
                
                    loadedStateView()
            }
            .padding(.horizontal, Constants.margin)
        }
        .toolbar(content: toolbarContent)
        .onAppear(perform: viewModel.pullToRefresh)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Body
private extension SearchView {
    @ViewBuilder
    func loadedStateView() -> some View {
        Group {
            filteringButtons()
            
            if !viewModel.searchIsActive {
                initialView()
                    .zStackTransition(.move(edge: .trailing))
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        if !viewModel.tracks.isEmpty {
                            tracksSection()
                        }
                        if !viewModel.artists.isEmpty {
                            artistsSection()
                        }
                        if !viewModel.albums.isEmpty {
                            albumsSection()
                        }
                        if !viewModel.playlists.isEmpty {
                            playlistsSection()
                        }
                    }
                    .background(.white)
                }
                .scrollDismissesKeyboard(.immediately)
                .refreshable(action: viewModel.pullToRefresh)
                .zStackTransition(.move(edge: .leading))
            }
        }
        .zStackTransition(.opacity)
    }
    
    func initialView() -> some View {
        VStack(spacing: 40) {
            Image.Search.arrowUp
                .resizable()
                .frame(width: 132, height: 132)
                .foregroundColor(.green400.opacity(0.75))
                .scaledToFit()
        
            Text(String.Search.tapToStart)
                .foregroundColor(.gray600)
                .frame(maxWidth: 120)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)
                .font(.nunitoBold(size: 18))
        }
        .ignoresSafeArea(edges: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    func filteringButtons() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: Constants.margin) {
                filteringButton(title: String.Search.filters, image: .Shared.filter, badgeToggled: viewModel.filteringOptions.count != 4) {
                    viewModel.filterButtonTapped()
                }
                .sheet(isPresented: $viewModel.isFilterPresented) {
                    FilterSheetView(viewModel: viewModel, isSheetPresented: $viewModel.isFilterPresented, isSort: false)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.hidden)
                }
                Spacer()
            }
            .padding(.horizontal, Constants.margin)
        }
    }
    
    @ViewBuilder
    func filteringButton(title: String, image: Image, badgeToggled: Bool, action: @escaping () -> Void) -> some View {
            HStack {
                Text(title)
                    .font(.nunitoBold(size: 18))
                    .foregroundColor(.gray600)
                image
                    .foregroundColor(.gray400)
            }
            .background { Color.white }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(RoundedRectangle(cornerRadius: Constants.cornerRadius).fill(.white))
            .background(RoundedRectangle(cornerRadius: Constants.cornerRadius).stroke(Color.gray400, lineWidth: 2))
            .mintBadge(isPresented: badgeToggled)
            .onTapGesture(perform: action)
    }
    
    @ViewBuilder
    func emptyStateView() -> some View {
        VStack(spacing: 16) {

        }
        .refreshGesture(offset: $gestureOffset, action: viewModel.pullToRefresh)
        .padding(Constants.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zStackTransition(.opacity)
    }
}

extension SearchView {
    @ViewBuilder
    func tracksSection() -> some View {
        VStack(alignment: .leading) {
            Text(String.Search.tracks)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray600)
            ForEach(Array(viewModel.tracks.enumerated()), id: \.offset) { enumeratedTrack in
                TrackRow(track: enumeratedTrack, isEnumerated: false, action: viewModel.trackOptionsTapped)
                    .background(.white)
                    .onTapGesture { viewModel.trackRowSelected(enumeratedTrack.element) }
            }
        }
    }
    
    func artistsSection() -> some View {
        VStack(alignment: .leading) {
            Text(String.Search.artists)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray600)
            ForEach(Array(viewModel.artists.enumerated()), id: \.offset) { enumeratedArtist in
                ArtistRow(artist: enumeratedArtist, isEnumerated: false, action: viewModel.artistOptionsTapped)
                    .background(.white)
                    .onTapGesture { viewModel.artistRowSelected(enumeratedArtist.element) }
            }
        }
    }
    
    func albumsSection() -> some View {
        VStack(alignment: .leading) {
            Text(String.Search.albums)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray600)
            
            ForEach(Array(viewModel.albums.enumerated()), id: \.offset) { enumeratedAlbum in
                AlbumRow(album: enumeratedAlbum, isEnumerated: false, action: viewModel.albumOptionsTapped)
                    .background(.white)
                    .onTapGesture { viewModel.albumRowSelected(enumeratedAlbum.element) }
            }
        }
    }
    
    func playlistsSection() -> some View {
        VStack(alignment: .leading) {
            Text(String.Search.playlists)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray600)
            ForEach(Array(viewModel.playlists.enumerated()), id: \.offset) { enumeratedPlaylist in
                PlaylistRow(playlist: enumeratedPlaylist, isEnumerated: false, action: viewModel.playlistOptionsTapped)
                    .background(.white)
                    .onTapGesture { viewModel.playlistRowSelected(enumeratedPlaylist.element) }
            }
        }
    }
}

// MARK: - Toolbar Content
extension SearchView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingLargeTitle(title: String.Tabs.search)
        
        ToolbarItem(placement: .navigationBarTrailing) {
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
    }
}
