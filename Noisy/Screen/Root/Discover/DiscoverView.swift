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
            Color.appBackground.ignoresSafeArea()
                .circleOverlay(xOffset: -0.6, yOffset: -0.4, frameMultiplier: 1.0, color: .mint600)
                .circleOverlay(xOffset: 0.7, yOffset: 0.6, color: .purple900.opacity(0.7))
            
            bodyView()
            headerView()
        }
        .ignoresSafeArea(edges: .top)
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
                    .fill(Color.yellow300)
                    .shadow(color: .gray500, radius: 2)
                    .frame(width: 160, height: 160)
                    .offset(x: 20, y: -30)
            }
        }
        .padding(Constants.margin)
        .padding(.top, 40)
    }
    
    func bodyView() -> some View {
            ScrollView {
                VStack {
                    Spacer(minLength: 140)
                    seedSelectionView()

                    recommendationResultsView()
                    Spacer(minLength: 80)
                }
            }
            .refreshable(action: viewModel.refreshToggled)
    }
    
    func seedSelectionView() -> some View {
        Group {
            CurrentSeedSelectionView(viewModel: viewModel, cropTitle: true)
            LargeButton(foregroundColor: .appBackground, backgroundColor: .purple600, title: .Discover.manageSeeds, action: viewModel.manageSeedsButtonTapped)
            LargeButton(foregroundColor: .appBackground, backgroundColor: .orange400, title: .Discover.changeSeedParameters, action: viewModel.changeSeedParametersButtonTapped)
        }
        .padding(.horizontal, Constants.margin)
    }
    
    @ViewBuilder
    func recommendationResultsView() -> some View {
        if viewModel.recommendedTracks.isEmpty {
            initialView()
        } else {
            recommendedTracks()
        }
    }
    
    func initialView() -> some View {
        VStack {
            LinearGradient(gradient: Gradient(colors: [.orange400, .yellow300, .white]), startPoint: .top, endPoint: .bottom)
                .mask {
                    Image.Shared.sunDust
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: Constants.mediumIconSize, height: Constants.mediumIconSize)
            
            Text(String.Discover.initialResultsMessage)
                .foregroundColor(.white)
                .font(.nunitoBold(size: 17))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 160)
        }
        .padding(.top, Constants.mediumIconSize)
    }
}

// MARK: - Recommended tracks
extension DiscoverView {
    func recommendedTracks() -> some View {
        VStack {
            SliderView(value: $viewModel.limit)
            LazyVStack(spacing: 4) {
                ForEach(Array(viewModel.recommendedTracks.enumerated()), id: \.offset) { enumeratedTrack in
                    TrackRow(track: enumeratedTrack, isEnumerated: false, action: viewModel.trackOptionsTapped)
                        .onTapGesture { viewModel.recommendedTrackRowSelected(enumeratedTrack.element) }
                }
            }
        }
        .padding(Constants.margin)
        .padding(.bottom, 50)
        .background {
            Color.appBackground
                .opacity(0.5)
                .blur(radius: 15)
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
