//
//  PlaylistView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct PlaylistView: View {
    @ObservedObject var viewModel: PlaylistViewModel
    @State var detents = Set<PresentationDetent>()

    var body: some View {
        bodyView()
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.isOptionsSheetPresented) {
                OptionsView(isPresented: $viewModel.isOptionsSheetPresented, options: viewModel.options)
                    .readSize { detents = [.height($0.height)] }
                    .presentationDetents(detents)
                    .toast(isPresented: $viewModel.isToastPresented, message: viewModel.toastMessage)
            }
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body view
extension PlaylistView {
    func bodyView() -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Constants.margin) {
                    headerView()
                    tracks()
                    relatedArtists()
                }
                .padding(.bottom, Constants.margin)
            }
            .ignoresSafeArea(edges: .top)
        }
    }
    
    func headerView() -> some View {
        ZStack(alignment: .bottomLeading) {
            LoadImage(url: URL(string: viewModel.playlist.images?.first?.url ?? .empty))
                .scaledToFit()
            LinearGradient(colors: [.clear, .clear, .clear, .gray600], startPoint: .top, endPoint: .bottom)
            HStack {
                Text(viewModel.playlist.name)
                    .font(.nunitoBold(size: 36))
                    .padding(Constants.margin)
                    .foregroundColor(.white)
                Button(action: viewModel.playlistOptionsTapped) {
                    Image.Shared.threeDots
                        .foregroundColor(.appBackground)
                }
            }
        }
    }
    
    @ViewBuilder
    func tracks() -> some View {
        if viewModel.tracks.isEmpty {
            
        } else {
            VStack(alignment: .leading) {
                Text(String.Search.tracks)
                    .font(.nunitoBold(size: 14))
                    .foregroundColor(.gray600)
                LazyVStack(spacing: 4) {
                    ForEach(Array(viewModel.tracks.enumerated()), id: \.offset) { enumeratedTrack in
                        TrackRow(track: enumeratedTrack, isEnumerated: false, action: viewModel.trackOptionsTapped)
                            .background(.white)
                            .onTapGesture { viewModel.trackRowTapped(for: enumeratedTrack.element) }
                    }
                }
            }
            .padding(Constants.margin)
        }
    }
    
    @ViewBuilder
    func relatedArtists() -> some View {
        if !viewModel.relatedArtists.isEmpty {
            VStack(alignment: .leading) {
                Text(String.Artist.related)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 20))
                    .padding(.horizontal, Constants.margin)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: Constants.margin) {
                        Color.appBackground
                            .frame(width: 1)
                        ForEach(viewModel.relatedArtists, id: \.id, content: relatedArtist)
                        Color.appBackground
                            .frame(width: 1)
                    }
                }
            }
            .zStackTransition(.slide)
        }
    }
    
    func relatedArtist(_ artist: Artist) -> some View {
        VStack {
            LoadImage(url: URL(string: artist.images?.first?.url ?? .empty))
                .frame(width: 100, height: 100)
                .cornerRadius(50)
            
            Text(artist.name)
                .foregroundColor(.gray600)
                .font(.nunitoSemiBold(size: 14))
                .multilineTextAlignment(.center)
                .frame(width: 100)
                .fixedSize(horizontal: false, vertical: true)
        }
        .onTapGesture { viewModel.artistButtonTapped(for: artist) }
    }
}

// MARK: - Toolbar
extension PlaylistView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingToolbarButton()
    }
    
    @ToolbarContentBuilder
    func leadingToolbarButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: viewModel.backButtonTapped) {
                ZStack {
                    Circle()
                        .fill(.white)
                    Image.Shared.chevronLeft
                        .foregroundColor(.gray800)
                        .padding(Constants.smallSpacing)
                }
            }
        }
    }
}
