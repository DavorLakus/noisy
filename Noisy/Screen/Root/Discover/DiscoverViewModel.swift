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
    @Published var isOptionsSheetPresented = false
    @Published var isToastPresented = false
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
    
    @Published var isRandomSeedsSelectionExpanded = false
    @Published var randomSeedCategory: SeedCategory = .artists
    @Published var seedCategory: SeedCategory = .artists
    @Published var isSearchActive = false
    @Published var query: String = .empty
    
    // MARK: - Coordinator actions
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    var onDidTapRecommendedTrackRow: PassthroughSubject<Track, Never>?
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumButton = PassthroughSubject<Album, Never>()
    
    // MARK: - Public properties
    var hasAnySeeds: Bool { !seedArtists.isEmpty || !seedTracks.isEmpty || !seedGenres.isEmpty }
    var notAllSeedParametersSelected: Bool { seedToggles.contains(false) }
    var options: [OptionRow] = []
    var toastMessage: String = .empty
    var profile: Profile? {
        guard let profile  = UserDefaults.standard.object(forKey: .Login.profile) as? Data
        else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: profile)
    }
    
    // MARK: - Private properties
    private var savedTracksLimit: Int = 10
    private var savedTracksOffset: Int = .zero
    private var savedTracksCount: Int = .zero
    private let discoverService: DiscoverService
    private let searchService: SearchService
    private let musicDetailsService: MusicDetailsService
    private let queueManager: QueueManager
    private var availableGenres: [String] = []
    private var canAddSeedEntities: Bool { seedArtists.count + seedTracks.count + seedGenres.count <= 5 }
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(discoverService: DiscoverService, searchService: SearchService, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.discoverService = discoverService
        self.searchService = searchService
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        getGenres()
        getSavedTracksCount()
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
        if !isSeedsSheetPresented,
           hasAnySeeds {
            discover()
        }
    }
    
    func changeSeedParametersButtonTapped() {
        withAnimation {
            isSeedParametersSheetPresented.toggle()
        }
        if !isSeedParametersSheetPresented,
           hasAnySeeds {
            discover()
        }
    }
    
    func generateRandomSeedsTapped() {
        generateRandomSeeds()
    }
    
    func randomSeedCategorySelected(_ category: SeedCategory) {
        withAnimation {
            randomSeedCategory = category
        }
        generateRandomSeeds()
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
        getGenres()
        discover()
    }
    
    func recommendedTrackRowSelected(_ track: Track) {
        onDidTapRecommendedTrackRow?.send(track)
    }
    
    func trackOptionsTapped(for track: Track) {
        options = [addToQueueOption(track), viewAlbumOption(track), viewArtistOption(track)]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
}

// MARK: - Track options
private extension DiscoverViewModel {
    func addToQueueOption(_ track: Track) -> OptionRow {
        let addToQueueSubject = PassthroughSubject<Void, Never>()
        
        addToQueueSubject
            .sink { [weak self] in
                self?.queueManager.append(track)
                self?.toastMessage = "\(track.name) \(String.Shared.addedToQueue)"
                withAnimation {
                    self?.isToastPresented = true
                }
            }
            .store(in: &cancellables)
        
        return OptionRow.addToQueue(action: addToQueueSubject)
    }
    
    func viewArtistOption(_ track: Track) -> OptionRow {
        let viewArtistSubject = PassthroughSubject<Void, Never>()
        
        viewArtistSubject
            .sink { [weak self] in
                withAnimation {
                    self?.isOptionsSheetPresented = false
                }
                self?.onDidTapArtistButton.send(track.artists[.zero])
            }
            .store(in: &cancellables)
        
        return OptionRow.viewArtist(action: viewArtistSubject)
    }
    
    func viewAlbumOption(_ track: Track) -> OptionRow {
        let viewAlbumSubject = PassthroughSubject<Void, Never>()
        
        viewAlbumSubject
            .sink { [weak self] in
                withAnimation {
                    self?.isOptionsSheetPresented = false
                }
                if let album = track.album {
                    self?.onDidTapAlbumButton.send(album)
                }
            }
            .store(in: &cancellables)
        
        return OptionRow.viewAlbum(action: viewAlbumSubject)
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
    
    func getSavedTracksCount() {
        musicDetailsService.getSavedTracks(limit: savedTracksLimit, offset: savedTracksOffset)
            .sink { [weak self] response in
                self?.savedTracksCount = response.total
            }
            .store(in: &cancellables)
    }
    
    func generateRandomSeeds() {
        resetSeeds()
        switch randomSeedCategory {
        case .artists:
            (0..<5).forEach { _ in
                musicDetailsService.getSavedTracks(limit: 1, offset: Int.random(in: (1...savedTracksCount)))
                    .sink { [weak self] response in
                        guard let self else { return }
                        if let artist = response.items.map(\.track).first?.artists.first,
                           !self.seedArtists.contains(artist) {
                            self.seedArtists.append(artist)
                        }
                    }
                    .store(in: &cancellables)
            }
        case .tracks:
            (0..<5).forEach { _ in
                musicDetailsService.getSavedTracks(limit: 1, offset: Int.random(in: (1...savedTracksCount)))
                    .sink { [weak self] response in
                        if let track = response.items.map(\.track).first {
                            self?.seedTracks.append(track)
                        }
                    }
                    .store(in: &cancellables)
            }
        default: break
        }
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
    
    func resetSeeds() {
        seedArtists = []
        seedTracks = []
        seedGenres = []
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
