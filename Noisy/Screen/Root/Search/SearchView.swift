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
                .circleOverlay(xOffset: -0.4, yOffset: 0.55, frameMultiplier: 1.8, color: .orange100.opacity(0.6))
                .circleOverlay(xOffset: -0.5, yOffset: 0.5, frameMultiplier: 1.5, color: .orange100)

            ZStack(alignment: .top) {
                bodyView()
                headerView()
            }
            .ignoresSafeArea(edges: .top)
        }
        .onAppear(perform: viewModel.pullToRefresh)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Body
private extension SearchView {
    @ViewBuilder
    func bodyView() -> some View {
        VStack(spacing: 12) {
            Spacer(minLength: 140)
            SearchBar(isActive: $viewModel.searchIsActive, query: $viewModel.query)
                .frame(height: 40)
                .background { Color.appBackground }
                .padding(.horizontal, Constants.margin)

            loadedStateView()
        }
    }
    
    @ViewBuilder
    func loadedStateView() -> some View {
        Group {
            filteringButtons()
            
            if !viewModel.searchIsActive {
                initialView()
                    .zStackTransition(.move(edge: .trailing))
            } else {
                ScrollView(showsIndicators: false) {
                   searchResultsView()
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
                .frame(width: Constants.mediumIconSize, height: Constants.mediumIconSize)
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
    
    func searchResultsView() -> some View {
        VStack {
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
            Spacer(minLength: 80)
        }
        .background {
            if viewModel.noData {
                Color.appBackground
                    .opacity(0.5)
                    .blur(radius: 15)
            }
        }
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

// MARK: - Search results sections
extension SearchView {
    @ViewBuilder
    func tracksSection() -> some View {
        sectionView(for: .Search.tracks) {
            ForEach(Array(viewModel.tracks.enumerated()), id: \.offset) { enumeratedTrack in
                TrackRow(track: enumeratedTrack, isEnumerated: false, action: viewModel.trackOptionsTapped)
                    .background(Color.appBackground.opacity(0.05))
                    .onTapGesture { viewModel.trackRowSelected(enumeratedTrack.element) }
            }
        }
    }
    
    func artistsSection() -> some View {
        sectionView(for: .Search.artists) {
            ForEach(Array(viewModel.artists.enumerated()), id: \.offset) { enumeratedArtist in
                ArtistRow(artist: enumeratedArtist, isEnumerated: false, action: viewModel.artistOptionsTapped)
                    .background(Color.appBackground.opacity(0.05))
                    .onTapGesture { viewModel.artistRowSelected(enumeratedArtist.element) }
            }
        }
    }
    
    func albumsSection() -> some View {
        sectionView(for: .Search.albums) {
            ForEach(Array(viewModel.albums.enumerated()), id: \.offset) { enumeratedAlbum in
                AlbumRow(album: enumeratedAlbum, isEnumerated: false, action: viewModel.albumOptionsTapped)
                    .background(Color.appBackground.opacity(0.05))
                    .onTapGesture { viewModel.albumRowSelected(enumeratedAlbum.element) }
            }
        }
    }
    
    func playlistsSection() -> some View {
        sectionView(for: .Search.playlists) {
            ForEach(Array(viewModel.playlists.enumerated()), id: \.offset) { enumeratedPlaylist in
                PlaylistRow(playlist: enumeratedPlaylist, isEnumerated: false, action: viewModel.playlistOptionsTapped)
                    .background(Color.appBackground.opacity(0.05))
                    .onTapGesture { viewModel.playlistRowSelected(enumeratedPlaylist.element) }
            }
        }
    }
    
    @ViewBuilder
    func sectionView<SectionList: View>(for type: String, list: () -> SectionList) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text(type)
                    .font(.nunitoBold(size: 18))
                    .padding(10)
                    .foregroundColor(.gray700)
                    .padding(.trailing, Constants.mediumIconSize)
            }
            .background {
                Color.appBackground.opacity(0.1).blur(radius: 2)
                    .circleOverlay(xOffset: 0.4, yOffset: .zero, frameMultiplier: 1.0, color: .yellow300.opacity(0.9))
                    .clipped()
            }
            .padding(.top, 8)
            
            list()
                .padding(.horizontal, Constants.margin)
        }
    }
}

// MARK: - Search filter buttons
extension SearchView {
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
}

// MARK: - Header view
private extension SearchView {
    func headerView() -> some View {
        HStack {
            Text(String.Tabs.search)
                .foregroundColor(.gray700)
                .font(.nunitoBold(size: 24))
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
