//
//  ArtistView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct ArtistView: View {
    @ObservedObject var viewModel: ArtistViewModel
    @State var detents = Set<PresentationDetent>()
    
    var body: some View {
        bodyView()
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
            .sheet(isPresented: $viewModel.isOptionsSheetPresented) {
                OptionsView(isPresented: $viewModel.isOptionsSheetPresented, options: viewModel.options)
                    .readSize { detents = [.height($0.height)] }
                    .presentationDetents(detents)
                    .toast(isPresented: $viewModel.isToastPresented, message: viewModel.toastMessage)
            }
    }
}

// MARK: - Body view
extension ArtistView {
    func bodyView() -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Constants.margin) {
                    headerView()
                    mostPlayed()
                    albums()
                    relatedArtists()
                    discoverButton()
                }
                .padding(.bottom, Constants.mediumIconSize)
            }
            .ignoresSafeArea(edges: .top)
        }
    }
    
    func headerView() -> some View {
        ZStack(alignment: .bottomLeading) {
            LoadImage(url: URL(string: viewModel.artist.images?.first?.url ?? .empty))
                .scaledToFit()
            LinearGradient(colors: [.clear, .clear, .clear, .gray600], startPoint: .top, endPoint: .bottom)
            Text(viewModel.artist.name)
                .font(.nunitoBold(size: 36))
                .padding(Constants.margin)
                .foregroundColor(.white)
        }
    }
    
    func mostPlayed() -> some View {
        SimpleAccordionView(isExpanded: $viewModel.isMostPlayedExpanded, title: "\(String.Artist.mostPlayed)", data: viewModel.topTracks.enumerated(), dataRowView: trackRow, action: viewModel.trackRowTapped, optionsAction: viewModel.trackOptionsTapped)
    }
    
    func albums() -> some View {
        SimpleAccordionView(isExpanded: $viewModel.isAlbumsExpanded, title: .Artist.albums, data: viewModel.albums.enumerated(), dataRowView: albumRow, action: viewModel.albumRowTapped, optionsAction: nil)
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
    
    func discoverButton() -> some View {
        Button(action: viewModel.discoverMoreButtonTapped) {
            Text(String.Discover.discoverMore)
                .font(.nunitoBold(size: 22))
                .foregroundColor(.purple600)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .cardBackground(gradient: LinearGradient(colors: [.yellow200, .yellow300], startPoint: .topLeading, endPoint: .bottomTrailing), borderColor: .mint600, hasBorder: true, hasShadow: false)
        .background {
            Color.gray500
                .shadow(radius: 4)
                .blur(radius: 4)
        }
        .padding(.horizontal, Constants.margin)
    }
}

// MARK: - Toolbar
extension ArtistView {
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
