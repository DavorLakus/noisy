//
//  CurrentSeedSelectionView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import SwiftUI

struct SeedCardModel: Hashable, Equatable {
    let title: String
    let subtitle: String?
    let id: String
    let background: Color
    let action: (String) -> Void
    let uuid = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    static func == (lhs: SeedCardModel, rhs: SeedCardModel) -> Bool {
        lhs.id != rhs.id
    }
    
    internal init(title: String, subtitle: String? = nil, id: String, background: Color, action: @escaping (String) -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.id = id
        self.background = background
        self.action = action
    }
}

struct CurrentSeedSelectionView: View {
    var title: String { viewModel.hasAnySeeds ? .Discover.currentSeedSelection : .Discover.pleaseSelectSomeDiscoverySeeds }
    @ObservedObject var viewModel: DiscoverViewModel
    let cropTitle: Bool
    
    init(viewModel: DiscoverViewModel, cropTitle: Bool = false) {
        self.viewModel = viewModel
        self.cropTitle = cropTitle
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.nunitoBold(size: 16))
                .foregroundColor(.gray700)
                .frame(maxWidth: .infinity)
            
            if !viewModel.seedArtists.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(viewModel.seedArtists, id: \.id) { artist in
                        SeedCard(model: SeedCardModel(title: artist.name, id: artist.id, background: .green200, action: viewModel.artistSeedCardSelected), cropTitle: cropTitle)
                    }
                }
            }
            
            if !viewModel.seedTracks.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(viewModel.seedTracks, id: \.id) { track in
                        SeedCard(model: SeedCardModel(title: track.name, subtitle: track.artists.first?.name, id: track.id, background: .orange400, action: viewModel.trackSeedCardSelected), cropTitle: cropTitle)
                    }
                }
            }
            
            if !viewModel.seedGenres.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(viewModel.seedGenres, id: \.self) { genre in
                        SeedCard(model: SeedCardModel(title: genre, id: genre, background: .blue400, action: viewModel.genreSeedCardSelected), cropTitle: cropTitle)
                    }
                }
            }
        }
        .padding(12)
        .cardBackground(backgroundColor: .yellow300.opacity(0.9), borderColor: .gray400, hasShadow: false)
    }
}
