//
//  SeedsSheetView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import SwiftUI

struct SeedsSheetView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @State var isGenerateRandomSeedsExpanded = false
    @Namespace var namespace
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: Constants.margin, alignment: nil),
        GridItem(.flexible(), spacing: Constants.margin, alignment: nil)
    ]
    
    var body: some View {
        VStack(spacing: Constants.margin) {
            headerView()
            searchSection()
        }
        .alert(isPresented: $viewModel.isInfoAlertPresented) { isPresented in
            AlertView(isPresented: isPresented, title: .Discover.generateRandomSeedsInfoTitle, message: .Discover.generateRandomSeedsInfoMessage, secondaryActionText: .Shared.ok)
        }
    }
}

extension SeedsSheetView {
    @ViewBuilder
    func headerView() -> some View {
        HStack {
            Spacer()
            Button(action: viewModel.manageSeedsButtonTapped) {
                Text(String.Shared.done)
                    .foregroundColor(.green500)
                    .font(.nunitoBold(size: 18))
            }
        }
        .padding([.horizontal, .top], Constants.margin)
        VStack(alignment: .leading) {
            Text(String.Discover.seedsTitle)
                .font(.nunitoBold(size: 18))
                .foregroundColor(.gray800)
            Text(String.Discover.seedsSubtitle)
                .font(.nunitoSemiBold(size: 13))
                .foregroundColor(.gray500)
        }
        .padding(.horizontal, Constants.margin)
    }
    
    func generateRandomSeedsButton() -> some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: viewModel.generateRandomSeedsTapped) {
                    Text(String.Discover.generateRandomSeeds)
                        .font(.nunitoBold(size: 17))
                }
                Button {
                    withAnimation {
                        viewModel.isInfoAlertPresented = true
                    }
                } label: {
                    Image.Shared.info
                        .foregroundColor(.green600)
                }
                
                Spacer()
                Button {
                    withAnimation {
                        isGenerateRandomSeedsExpanded.toggle()
                    }
                } label: {
                    Image.Shared.chevronRight
                        .rotationEffect(.degrees(isGenerateRandomSeedsExpanded ? 90 : .zero ))
                }
            }
            if isGenerateRandomSeedsExpanded {
                HStack {
                    Text("For:")
                        .font(.nunitoSemiBold(size: 14))
                        .foregroundColor(.gray600)
                    
                    Button { viewModel.randomSeedCategorySelected(.artists) } label: {
                        HStack {
                            (viewModel.randomSeedCategory == .artists ? Image.Shared.checkboxFill : Image.Shared.checkbox)
                            Text(String.Search.artists)
                                .font(.nunitoBold(size: 14))
                                .foregroundColor(.gray600)
                        }
                    }
                    
                    Button { viewModel.randomSeedCategorySelected(.tracks) } label: {
                        HStack {
                            (viewModel.randomSeedCategory == .tracks ? Image.Shared.checkboxFill : Image.Shared.checkbox)
                            Text(String.Search.tracks)
                                .font(.nunitoBold(size: 14))
                                .foregroundColor(.gray600)

                        }
                    }
                }
            }
        }
        .padding(12)
        .cardBackground(backgroundColor: .yellow300, borderColor: .gray600, hasShadow: false)
        .padding(.vertical, 3)
    }
    
    func searchSection() -> some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: Constants.margin) {
                generateRandomSeedsButton()
                CurrentSeedSelectionView(viewModel: viewModel)
                searchTabBar()
                
                SearchBar(isActive: $viewModel.isSearchActive, query: $viewModel.query, placeholder: "\(String.Tabs.search) \(String(describing: viewModel.seedCategory))...")
                
                VStack {
                    switch viewModel.seedCategory {
                    case .artists:
                        artistsSection()
                    case .tracks:
                        tracksSection()
                    case .genres:
                        genresSection()
                    }
                }
                
            }
            .padding(.horizontal, Constants.margin)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }
    
    func searchTabBar() -> some View {
        HStack {
            ForEach(SeedCategory.allCases, id: \.self) { seedCategory in
                Text(seedCategory.displayName)
                    .padding(12)
                    .font(viewModel.seedCategory == seedCategory ? .nunitoBold(size: 16) : .nunitoSemiBold(size: 16))
                    .foregroundColor(viewModel.seedCategory == seedCategory ? .appBackground : .green500)
                    .background {
                        if viewModel.seedCategory == seedCategory {
                            RoundedRectangle(cornerRadius: Constants.cornerRadius).stroke(Color.green600, lineWidth: 3)
                                .background {
                                    RoundedRectangle(cornerRadius: Constants.cornerRadius).fill(Color.mint600)
                                }
                                .matchedGeometryEffect(id: String.Tabs.discover, in: namespace)
                        }
                    }
                    .padding(3)
                    .onTapGesture {
                        viewModel.seedCategorySelected(seedCategory)
                    }
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    func tracksSection() -> some View {
        if !viewModel.tracks.isEmpty {
            VStack(alignment: .leading) {
                Text(String.Search.tracks)
                    .font(.nunitoBold(size: 14))
                    .foregroundColor(.gray600)
                ForEach(Array(viewModel.tracks.enumerated()), id: \.offset) { enumeratedTrack in
                    TrackRow(track: enumeratedTrack, isEnumerated: false)
                        .background(.white)
                        .onTapGesture { viewModel.trackRowSelected(enumeratedTrack.element) }
                }
            }
        } else {
            initialView()
        }
    }
    
    @ViewBuilder
    func artistsSection() -> some View {
        if !viewModel.artists.isEmpty {
            VStack(alignment: .leading) {
                Text(String.Search.artists)
                    .font(.nunitoBold(size: 14))
                    .foregroundColor(.gray600)
                ForEach(Array(viewModel.artists.enumerated()), id: \.offset) { enumeratedArtist in
                    ArtistRow(artist: enumeratedArtist, isEnumerated: false)
                        .background(.white)
                        .onTapGesture { viewModel.artistRowSelected(enumeratedArtist.element) }
                }
            }
        } else {
            initialView()
        }
    }
    
    @ViewBuilder
    func genresSection() -> some View {
        if !viewModel.genres.isEmpty {
            VStack(alignment: .leading) {
                Text(viewModel.isSearchActive ? String.Search.genres : String.Search.allGenres)
                    .font(.nunitoBold(size: 14))
                    .foregroundColor(.gray600)
                
                LazyVGrid(columns: columns, spacing: Constants.margin) {
                    ForEach(viewModel.genres, id: \.self) { genre in
                        HStack {
                            Text(genre)
                                .foregroundColor(.gray700)
                                .font(.nunitoBold(size: 16))
                                .padding(12)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .cardBackground()
                        .onTapGesture { viewModel.genreRowSelected(genre) }
                    }
                }
            }
            .padding(Constants.margin)
        }
    }
    
    @ViewBuilder
    func initialView() -> some View {
        VStack(spacing: 40) {
            Spacer(minLength: 80)
            Image.Search.arrowUp
                .resizable()
                .frame(width: 60, height: 60)
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
}
