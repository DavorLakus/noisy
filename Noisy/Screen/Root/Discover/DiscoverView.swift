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
        bodyView()
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body view
extension DiscoverView {
    func bodyView() -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack {
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
        .sheet(isPresented: $viewModel.isSeedParametersSheetPresented) {
            SeedParametersSheetView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isSeedsSheetPresented) {
            SeedsSheetView(viewModel: viewModel)
        }
    }
}

struct SliderView: View {
    @Binding var value: Double
    let min: Double
    let max: Double
    
    init(value: Binding<Double>, min: Double = 1, max: Double = 50) {
        _value = value
        self.min = min
        self.max = max
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(String.Home.sliderCount) \(Int(value))")
                .font(.nunitoSemiBold(size: 14))
                .foregroundColor(.gray700)
            
            HStack(spacing: Constants.smallSpacing) {
                Text("\(Int(min))")
                    .font(.nunitoRegular(size: 12))
                    .foregroundColor(.gray500)
                Slider(value: $value, in: min...max)
                Text("\(Int(max))")
                    .font(.nunitoRegular(size: 12))
                    .foregroundColor(.gray500)
            }
        }
    }
}

extension DiscoverView {
    func recommendedTracks() -> some View {
        VStack(alignment: .leading) {
            Text(String.Search.tracks)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray600)
            LazyVStack(spacing: 4) {
                ForEach(Array(viewModel.recommendedTracks.enumerated()), id: \.offset) { enumeratedTrack in
                    TrackRow(track: enumeratedTrack, isEnumerated: false)
                        .background(.white)
                        .onTapGesture { viewModel.trackRowSelected(enumeratedTrack.element) }
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
