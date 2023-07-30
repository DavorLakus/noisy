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
    @Published var seedToggles = [Bool](repeating: true, count: 14)
    @Published var seedArtists: [Artist] = []
    @Published var seedTracks: [Track] = []
    @Published var seedGenres: [String] = []
    
    @Published var artists: [Artist] = []
    @Published var tracks: [Track] = []
    @Published var genres: [String] = []
    
    @Published var seedCategory: SeedCategory = .artists
    @Published var isSearchActive = false
    @Published var query: String = .empty
    var notAllSeedsSelected: Bool { seedToggles.contains(false) }
    
    // MARK: - Coordinator actions
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    
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
    
    func changeSeedsButtonTapped() {
        withAnimation {
            isSeedsSheetPresented.toggle()
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
            seedToggles = seedToggles.map { _ in notAllSeedsSelected ? true : false }
        }
    }
    
    func discoverButtonTapped() {
        discoverService.discover(seedParameters: createDiscoverQueryParameters())
            .sink { _ in
//                print(result)
            }
            .store(in: &cancellables)
    }
    
    
    func checkIfSeedToggled(seedIndex: Int, value: String) -> String? {
        seedToggles[seedIndex] ? value : nil
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
            query = .empty
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
                genres = availableGenres.filter { $0.contains(query) }
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
    
    func createDiscoverQueryParameters() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "market", value: "HR"),
            URLQueryItem(name: "limit", value:  "10"),
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
        
        queryItems.forEach { print($0) }
        return queryItems
    }
}
