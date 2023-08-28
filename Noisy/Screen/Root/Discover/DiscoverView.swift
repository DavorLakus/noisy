//
//  DiscoverView.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()
                .circleOverlay(xOffset: -0.6, yOffset: -0.4, frameMultiplier: 0.9, color: .mint600.opacity(0.4))
                .circleOverlay(xOffset: 0.7, yOffset: 0.6, color: .purple900.opacity(0.4))
            
            bodyView()
            headerView()
        }
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .dynamicModalSheet(isPresented: $viewModel.isOptionsSheetPresented) {
            OptionsView(isPresented: $viewModel.isOptionsSheetPresented, options: viewModel.options)
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
                ScrollViewReader { scrollProxy in
                    VStack {
                        Spacer(minLength: 140)
                        seedSelectionView()
                        
                        recommendationResultsView()
                            .onChange(of: viewModel.recommendedTracks) { tracks in
                                if !tracks.isEmpty {
                                    withAnimation {
                                        scrollProxy.scrollTo(String.Discover.discover, anchor: .top)
                                    }
                                }
                            }
                        Spacer(minLength: 80)
                    }
                }
            }
            .refreshable(action: viewModel.refreshToggled)
    }
    
    func seedSelectionView() -> some View {
        Group {
            CurrentSeedSelectionView(viewModel: viewModel, cropTitle: true)
            SliderView(value: $viewModel.limit)
            LargeButton(foregroundColor: .appBackground, backgroundColor: .purple600, title: .Discover.manageSeeds, action: viewModel.manageSeedsButtonTapped)
            LargeButton(foregroundColor: .appBackground, backgroundColor: .mint600, title: .Discover.changeSeedParameters, action: viewModel.changeSeedParametersButtonTapped)
                .id(String.Discover.discover)
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
            HStack(spacing: Constants.margin) {
                Text(String.Discover.recommendations)
                    .font(.nunitoBold(size: 24))
                    .foregroundColor(.gray700)

                Button(action: viewModel.recommendationsOptionsTapped) {
                    Image.Shared.threeDots
                }
                
                Button(action: viewModel.onDidTapDiscoverButton) {
                    Image.Shared.refresh
                }
                Spacer()
            }
            LazyVStack(spacing: 4) {
                ForEach(Array(viewModel.recommendedTracks.enumerated()), id: \.offset) { enumeratedTrack in
                    TrackRow(track: enumeratedTrack, isEnumerated: false, action: viewModel.trackOptionsTapped)
                        .onTapGesture { viewModel.recommendedTrackRowSelected(enumeratedTrack.element) }
                }
            }
            
           visualizeButton()
        }
        .padding(Constants.margin)
        .padding(.bottom, 50)
        .background {
            Color.appBackground
                .opacity(0.6)
                .blur(radius: 15)
        }
    }
    
    func visualizeButton() -> some View {
        Button(action: viewModel.visualizeButtonTapped) {
            Text(String.Visualize.visualize)
                .font(.nunitoBold(size: 28))
                .foregroundStyle(
                    LinearGradient(colors: [.green200, .purple600, .green500, .mint600, .red200, .purple300, .mint600, .green300, .purple600], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .cardBackground(gradient: LinearGradient(colors: [.white], startPoint: .topLeading, endPoint: .bottomTrailing), borderColor: .red600, hasBorder: true, hasShadow: false)
        .background {
            Color.gray500
                .shadow(radius: 4)
                .blur(radius: 4)
        }
        .padding(.vertical, Constants.margin)
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
