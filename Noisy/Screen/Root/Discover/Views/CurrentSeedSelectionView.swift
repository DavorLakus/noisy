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
    @State var artistSeedCardModels = [SeedCardModel]()
    @State var trackSeedCardModels = [SeedCardModel]()
    @State var genreSeedCardModels = [SeedCardModel]()
    @State var containerWidth: CGFloat = .zero
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
                    ForEach(artistSeedCardModels, id: \.id) { artistModel in
                        SeedCard(model: artistModel, cropTitle: cropTitle)
                    }
                }
                .onChange(of: viewModel.seedArtists) { _ in
                    setupFlowGrid(for: .artists)
                }
            }
            
            if !viewModel.seedTracks.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(trackSeedCardModels, id: \.id) { trackModel in
                        SeedCard(model: trackModel, cropTitle: cropTitle)
                    }
                }
                .onChange(of: viewModel.seedTracks) { _ in
                    setupFlowGrid(for: .tracks)
                }
            }
            
            if !viewModel.seedGenres.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(genreSeedCardModels, id: \.self) { genreModel in
                        SeedCard(model: genreModel, cropTitle: cropTitle)
                    }
                }
                .onChange(of: viewModel.seedGenres) { _ in
                    setupFlowGrid(for: .genres)
                }
            }
        }
        .padding(12)
        .cardBackground(backgroundColor: .yellow300.opacity(0.9), borderColor: .gray400, hasShadow: false)
    }
}

// MARK: - Private extension
private extension CurrentSeedSelectionView {
    func setupFlowGrid(for type: SeedCategory) {
        switch type {
        case .artists:
            artistSeedCardModels = viewModel.seedArtists.map { artist in
                SeedCardModel(title: artist.name, id: artist.id, background: .green200, action: viewModel.artistSeedCardSelected)
            }
        case .tracks:
            trackSeedCardModels = viewModel.seedTracks.map { track in
                SeedCardModel(title: track.name, subtitle: track.artists.first?.name, id: track.id, background: .orange400, action: viewModel.trackSeedCardSelected)
            }
        case .genres:
            genreSeedCardModels = viewModel.seedGenres.map { genre in
                SeedCardModel(title: genre, id: genre, background: .blue400, action: viewModel.genreSeedCardSelected)
            }
        }
    }
}
