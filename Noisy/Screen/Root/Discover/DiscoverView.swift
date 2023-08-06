//
//  DiscoverView.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @State var detents = Set<PresentationDetent>()
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea(edges: .top)
                .circleOverlay(xOffset: -0.8, yOffset: 0.8)
            
            ZStack(alignment: .top) {
                bodyView()
                headerView()
            }
            .ignoresSafeArea(edges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.isOptionsSheetPresented) {
            OptionsView(isPresented: $viewModel.isOptionsSheetPresented, options: viewModel.options)
                .readSize { detents = [.height($0.height)] }
                .presentationDetents(detents)
                .toast(isPresented: $viewModel.isToastPresented, message: viewModel.toastMessage)
        }
        .sheet(isPresented: $viewModel.isSeedParametersSheetPresented) {
            SeedParametersSheetView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isSeedsSheetPresented) {
            SeedsSheetView(viewModel: viewModel)
        }
    }
}

// MARK: - Body view
extension DiscoverView {
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
                    .fill(Color.appBackground)
                    .shadow(color: .gray500, radius: 2)
                    .frame(width: 160, height: 160)
                    .offset(x: 20, y: -30)
            }
        }
        .padding(Constants.margin)
        .padding(.top, 40)
    }
    
    func bodyView() -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
                .circleOverlay(xOffset: 0.7, yOffset: 0.6, color: .purple900)
            
            ScrollView {
                VStack {
                    Spacer(minLength: 120)
                    CurrentSeedSelectionView(viewModel: viewModel)
                    LargeButton(foregroundColor: .appBackground, backgroundColor: .purple600, title: .Discover.manageSeeds, action: viewModel.manageSeedsButtonTapped)
                    LargeButton(foregroundColor: .appBackground, backgroundColor: .orange400, title: .Discover.changeSeedParameters, action: viewModel.changeSeedParametersButtonTapped)
                    if viewModel.recommendedTracks.isEmpty {
                        Spacer()
                    } else {
                        SliderView(value: $viewModel.limit)
                        recommendedTracks()
                    }
                }
                .padding(Constants.margin)
            }
            .refreshable(action: viewModel.refreshToggled)
        }
    }
}

// MARK: - Recommended tracks
extension DiscoverView {
    func recommendedTracks() -> some View {
        VStack(alignment: .leading) {
            Text(String.Search.tracks)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray600)
            LazyVStack(spacing: 4) {
                ForEach(Array(viewModel.recommendedTracks.enumerated()), id: \.offset) { enumeratedTrack in
                    TrackRow(track: enumeratedTrack, isEnumerated: false, action: viewModel.trackOptionsTapped)
                        .background(.white)
                        .onTapGesture { viewModel.recommendedTrackRowSelected(enumeratedTrack.element) }
                }
            }
        }
    }
}

// MARK: - Toolbar
extension DiscoverView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
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
