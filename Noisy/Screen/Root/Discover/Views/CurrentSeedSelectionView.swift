//
//  CurrentSeedSelectionView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import SwiftUI

struct CurrentSeedSelectionView: View {
    var title: String { viewModel.hasAnySeeds ? .Discover.currentSeedSelection : .Discover.pleaseSelectSomeDiscoverySeeds }
    @ObservedObject var viewModel: DiscoverViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.nunitoBold(size: 16))
                .foregroundColor(viewModel.hasAnySeeds ? .green300 : .green500)
                .frame(maxWidth: .infinity)
            
            if !viewModel.seedArtists.isEmpty {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.seedArtists, id: \.id) {
                        SeedCard(title: $0.name, id: $0.id, background: .green200, action: viewModel.artistSeedCardSelected)
                    }
                }
            }
                
            if !viewModel.seedTracks.isEmpty {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.seedTracks, id: \.id) {
                        SeedCard(title: $0.name, id: $0.id, background: .orange400, action: viewModel.trackSeedCardSelected)
                    }
                }
            }
                
            if !viewModel.seedGenres.isEmpty {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.seedGenres, id: \.self) {
                        SeedCard(title: $0, id: $0, background: .blue400, action: viewModel.genreSeedCardSelected)
                    }
                }
            }
        }
        .padding(Constants.smallSpacing)
        .cardBackground(backgroundColor: viewModel.hasAnySeeds ? .yellow100 : .yellow200)
    }
}
