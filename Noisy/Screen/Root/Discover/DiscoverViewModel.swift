//
//  DiscoverViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI
import Combine

enum SeedCategory: CaseIterable, Hashable {
    case artists
    case tracks
    case genres
    
    var displayName: String {
        switch self {
        case .artists:
            return "Artists"
        case .tracks:
            return "Tracks"
        case .genres:
            return "Genres"
        }
    }
    
    var type: String {
        switch self {
        case .artists:
            return "artist"
        case .tracks:
            return "track"
        case .genres:
            return "genre"
        }
    }
}

final class DiscoverViewModel: ObservableObject {
    // MARK: Published properties
    @Published var isSeedsSheetPresented = false
    @Published var lowerBounds = [Double](repeating: 0.0, count: 14)
    @Published var targets = [Double](repeating: 0.5, count: 14)
    @Published var upperBounds = [Double](repeating: 1.0, count: 14)
    @Published var seedArtists: [Artist] = []
    @Published var seedTracks: [Track] = []
    @Published var seedGenres: [String] = []
    
    @Published var artists: [Artist] = []
    @Published var tracks: [Track] = []
    @Published var genres: [String] = []
    
    @Published var seedCategory: SeedCategory = .artists
    @Published var isSearchActive = false
    @Published var query: String = .empty
    
    // MARK: - Coordinator actions
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private let discoverService: DiscoverService
    private let searchService: SearchService
    private var availableGenres: [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public properties
    var profile: Profile? {
        guard let profile  = UserDefaults.standard.object(forKey: .Login.profile) as? Data
        else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: profile)
    }
    
    // MARK: - Class lifecycle
    init(discoverService: DiscoverService, searchService: SearchService) {
        self.discoverService = discoverService
        self.searchService = searchService
        
        getGenres()
        bind()
    }
}

extension DiscoverViewModel {
    func profileButtonTapped() {
        onDidTapProfileButton.send()
    }
    
    func changeSeedsButtonTapped() {
        withAnimation {
            isSeedsSheetPresented.toggle()
        }
    }
    
    func artistRowSelected(_ artist: Artist) {
        withAnimation {
            seedArtists.append(artist)
        }
    }
    
    func trackRowSelected(_ track: Track) {
        withAnimation {
            seedTracks.append(track)
        }
    }
    
    func genreRowSelected(_ genre: String) {
        withAnimation {
            seedGenres.append(genre)
        }
    }
    
    func artistSeedCardSelected(_ artistId: String) {
        withAnimation {
            seedArtists.removeAll {
                $0.id == artistId
            }
        }
    }
    
    func trackSeedCardSelected(_ trackId: String) {
        withAnimation {
            seedTracks.removeAll {
                $0.id == trackId
            }
        }
    }
    
    func genreSeedCardSelected(_ genre: String) {
        withAnimation {
            seedGenres.removeAll {
                $0 == genre
            }
        }
    }
    
    func discoverButtonTapped() {
        let request = DiscoverRequest(
            limit: 10,
            seedArtists: seedArtists.map(\.id).joined(separator: ","),
            seedGenres: seedGenres.joined(separator: ","),
            seedTracks: seedTracks.map(\.id).joined(separator: ","),
            minAcousticness: lowerBounds[Seed.acousticness.id],
            maxAcousticness: upperBounds[Seed.acousticness.id],
            targetAcousticness: targets[Seed.acousticness.id],
            minDanceability: lowerBounds[Seed.danceability.id],
            maxDanceability: upperBounds[Seed.danceability.id],
            targetDanceability: targets[Seed.danceability.id],
            minDurationMs: Int(lowerBounds[Seed.duration.id]),
            maxDurationMs: Int(upperBounds[Seed.duration.id]),
            targetDurationMs: Int(targets[Seed.duration.id]),
            minEnergy: lowerBounds[Seed.energy.id],
            maxEnergy: upperBounds[Seed.energy.id],
            targetEnergy: targets[Seed.energy.id],
            minInstrumentalness: lowerBounds[Seed.instrumentalness.id],
            maxInstrumentalness: upperBounds[Seed.instrumentalness.id],
            targetInstrumentalness: targets[Seed.instrumentalness.id],
            minKey: lowerBounds[Seed.key.id],
            maxKey: upperBounds[Seed.key.id],
            targetKey: targets[Seed.key.id],
            minLiveness: lowerBounds[Seed.liveness.id],
            maxLiveness: upperBounds[Seed.liveness.id],
            targetLiveness: targets[Seed.liveness.id],
            minLoudness: lowerBounds[Seed.loudness.id],
            maxLoudness: upperBounds[Seed.loudness.id],
            targetLoudness: targets[Seed.loudness.id],
            minMode: lowerBounds[Seed.mode.id],
            maxMode: upperBounds[Seed.mode.id],
            targetMode: targets[Seed.mode.id],
            minPopularity: lowerBounds[Seed.popularity.id],
            maxPopularity: upperBounds[Seed.popularity.id],
            targetPopularity: targets[Seed.popularity.id],
            minSpeechiness: lowerBounds[Seed.speechiness.id],
            maxSpeechiness: upperBounds[Seed.speechiness.id],
            targetSpeechiness: targets[Seed.speechiness.id],
            minTempo: lowerBounds[Seed.tempo.id],
            maxTempo: upperBounds[Seed.tempo.id],
            targetTempo: targets[Seed.tempo.id],
            minTimeSignature: lowerBounds[Seed.timeSignature.id],
            maxTimeSignature: upperBounds[Seed.timeSignature.id],
            targetTimeSignature: targets[Seed.timeSignature.id],
            minValence: lowerBounds[Seed.valence.id],
            maxValence: upperBounds[Seed.valence.id],
            targetValence: targets[Seed.valence.id]
        )
        
        discoverService.discover(request: request)
            .sink { result in
                print(result)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private extension
private extension DiscoverViewModel {
    func bind() {
        $isSearchActive
            .dropFirst()
            .sink { [weak self] isActive in
                if isActive {
                    self?.reloadResults(searchActivated: true)
                } else {
                    self?.query = .empty
                    self?.resetSearchResults()
                }
            }
            .store(in: &cancellables)
        
        $seedCategory
            .sink { [weak self] _ in
                withAnimation {
                    self?.resetSearchResults()
                    self?.reloadResults()
                }
            }
            .store(in: &cancellables)
        
        $query
            .debounce(for: .seconds(0.4), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation {
                    self?.reloadResults()
                }
            }
            .store(in: &cancellables)
    }
    
    func resetSearchResults() {
        withAnimation {
            artists = []
            tracks = []
            genres = []
        }
    }
    
    func reloadResults(searchActivated: Bool = false) {
        let limit = 10
        if !query.isEmpty {
            if seedCategory != .genres {
                searchService.search(for: query, type: seedCategory.type, limit: limit, offset: .zero)
                    .sink { [weak self] searchResult in
                        if let tracksResponse = searchResult.tracks {
                            self?.tracks = tracksResponse.items
                        }
                        if let artistsResponse = searchResult.artists {
                            self?.artists = artistsResponse.items
                        }
                    }
                    .store(in: &cancellables)
            } else {
                genres = genres.filter { $0.contains(query) }
            }
        }
    }
    
    func getGenres() {
        discoverService.getRecommendationGenres()
            .sink { [weak self] genres in
                self?.availableGenres = genres
            }
            .store(in: &cancellables)
    }
}
