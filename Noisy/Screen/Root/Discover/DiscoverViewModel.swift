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
    @Published var isSeedParametersSheetPresented = false
    @Published var limit: Double = 10
    @Published var lowerBounds = [Double](repeating: 0.0, count: 14)
    @Published var targets = [Double](repeating: 0.5, count: 14)
    @Published var upperBounds = [Double](repeating: 1.0, count: 14)
    @Published var seedToggles = [Bool](repeating: false, count: 14)
    @Published var seedArtists: [Artist] = []
    @Published var seedTracks: [Track] = []
    @Published var seedGenres: [String] = []
    
    @Published var artists: [Artist] = []
    @Published var tracks: [Track] = []
    @Published var genres: [String] = []
    @Published var recommendedTracks: [Track] = []
    
    @Published var seedCategory: SeedCategory = .artists
    @Published var isSearchActive = false
    @Published var query: String = .empty
    var hasAnySeeds: Bool { !seedArtists.isEmpty || !seedTracks.isEmpty || !seedGenres.isEmpty }
    var notAllSeedParametersSelected: Bool { seedToggles.contains(false) }
    
    // MARK: - Coordinator actions
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    var onDidTapRecommendedTrackRow: PassthroughSubject<Track, Never>?
    
    // MARK: - Private properties
    private let discoverService: DiscoverService
    private let searchService: SearchService
    private var availableGenres: [String] = []
    private var canAddSeedEntities: Bool { seedArtists.count + seedTracks.count + seedGenres.count <= 5 }
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
    
    func manageSeedsButtonTapped() {
        withAnimation {
            isSeedsSheetPresented.toggle()
        }
        if !isSeedsSheetPresented {
            discover()
        }
    }
    
    func changeSeedParametersButtonTapped() {
        withAnimation {
            isSeedParametersSheetPresented.toggle()
        }
        if !isSeedParametersSheetPresented {
            discover()
        }
    }
    
    func seedCategorySelected(_ category: SeedCategory) {
        withAnimation {
            seedCategory = category
        }
    }
    
    func artistRowSelected(_ artist: Artist) {
        if canAddSeedEntities {
            withAnimation {
                seedArtists.append(artist)
            }
        }
    }
    
    func trackRowSelected(_ track: Track) {
        if canAddSeedEntities {
            withAnimation {
                seedTracks.append(track)
            }
        }
    }
    
    func genreRowSelected(_ genre: String) {
        if canAddSeedEntities {
            withAnimation {
                seedGenres.append(genre)
            }
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
    
    func selectAllSeedsTapped() {
        withAnimation {
            seedToggles = seedToggles.map { _ in notAllSeedParametersSelected ? true : false }
        }
    }
    
    func discoverButtonTapped() {
        discover()
    }
    
    func checkIfSeedToggled(seedIndex: Int, value: String) -> String? {
        seedToggles[seedIndex] ? value : nil
    }
    
    @Sendable
    func refreshToggled() {
        discover()
    }
    
    func recommendedTrackRowSelected(_ track: Track) {
        onDidTapRecommendedTrackRow?.send(track)
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
        
        $limit
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.discover()
            }
            .store(in: &cancellables)
    }
    
    func discover() {
        discoverService.discover(seedParameters: createDiscoverQueryParameters())
            .sink { [weak self] result in
                withAnimation {
                    self?.recommendedTracks = result.tracks
                }
            }
            .store(in: &cancellables)
    }
    
    func resetSearchResults() {
        withAnimation {
            query = .empty
            artists = []
            tracks = []
            genres = isSearchActive ? [] : availableGenres
        }
    }
    
    func reloadResults(searchActivated: Bool = false) {
        let limit = 10
        if !query.isEmpty {
            if seedCategory != .genres {
                print("searching for \(seedCategory.displayName)")
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
                genres = availableGenres.filter { $0.contains(query) }
            }
        } else {
            resetSearchResults()
        }
    }
    
    func getGenres() {
        discoverService.getRecommendationGenres()
            .sink { [weak self] genres in
                self?.availableGenres = genres
            }
            .store(in: &cancellables)
    }
    
    func createDiscoverQueryParameters() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "market", value: "HR"),
            URLQueryItem(name: "limit", value:  "\(Int(limit))"),
            URLQueryItem(name: "seed_artists", value: seedArtists.map(\.id).joined(separator: ",")),
            URLQueryItem(name: "seed_genres", value: seedGenres.joined(separator: ",")),
            URLQueryItem(name: "seed_tracks", value: seedTracks.map(\.id).joined(separator: ","))
        ]
        
        Seed.allCases.forEach { seed in
            if seedToggles[seed.id] {
                queryItems.append(URLQueryItem(name: seed.minCodingKey, value: seed.valueToString(value: lowerBounds[seed.id])))
                queryItems.append(URLQueryItem(name: seed.maxCodingKey, value: seed.valueToString(value: upperBounds[seed.id])))
                queryItems.append(URLQueryItem(name: seed.targetCodingKey, value: seed.valueToString(value: targets[seed.id])))
            }
        }
        
        return queryItems
    }
}
