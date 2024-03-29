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
    @Published var isInfoAlertPresented = false
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
    @Published var infoSeed: Seed?
    @Published var isSearchActive = false
    @Published var query: String = .empty
    
    // MARK: - Coordinator actions
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    var onDidTapRecommendedTrackRow: PassthroughSubject<Void, Never>?
    var onDidTapSeedInfoButton: PassthroughSubject<Seed, Never>?
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumButton = PassthroughSubject<Album, Never>()
    let onDidTapAddToPlaylist = PassthroughSubject<[Track], Never>()
    let onDidTapVisualizeButton = PassthroughSubject<[Track], Never>()
    
    // MARK: - Public properties
    var hasAnySeeds: Bool { !seedArtists.isEmpty || !seedTracks.isEmpty || !seedGenres.isEmpty }
    var notAllSeedParametersSelected: Bool { seedToggles.contains(false) }
    var options: [Option] = []
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
    private var recommendedTracksBuffer: [Track] = []
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

// MARK: - Public extension
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
    
    func seedInfoTapped(for seed: Seed) {
        infoSeed = seed
        withAnimation {
            isInfoAlertPresented = true
        }
    }
    
    func onDidTapDiscoverButton() {
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
    
    func recommendationsOptionsTapped() {
        options = [addRecommendationsToQueueOption(), addRecommendationsToSpotifyQueueOption(), addRecommendationsToPlaylistOption()]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
    
    func recommendedTrackRowSelected(_ track: Track) {
        queueManager.setState(with: recommendedTracks, currentTrackIndex: recommendedTracks.firstIndex(of: track))
        onDidTapRecommendedTrackRow?.send()
    }
    
    func trackOptionsTapped(for track: Track) {
        options = [addToQueueOption(track), addTrackToSpotifyQueueOption(track), viewAlbumOption(track), viewArtistOption(track), addToPlaylistOption(track)]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
    
    func visualizeButtonTapped() {
        onDidTapVisualizeButton.send(recommendedTracks)
    }
}

// MARK: - Track options
private extension DiscoverViewModel {
    func addRecommendationsToQueueOption() -> Option {
        let addToQueueSubject = PassthroughSubject<Void, Never>()
        
        addToQueueSubject
            .sink { [weak self] in
                guard let self else { return }
                self.queueManager.append(self.recommendedTracks)
                self.toastMessage = "\(String.Discover.recommendations) \(String.Shared.addedToQueue)"
                withAnimation {
                    self.isToastPresented = true
                }
            }
            .store(in: &cancellables)
        
        return Option.addToQueue(action: addToQueueSubject)
    }
    
    func addRecommendationsToSpotifyQueueOption() -> Option {
        let addToQueueSubject = PassthroughSubject<Void, Never>()
        
        addToQueueSubject
            .sink { [weak self] in
                guard let self else { return }
                self.addTracksToSpotifyQueue()
            }
            .store(in: &cancellables)
        
        return Option.addToSpotifyQueue(action: addToQueueSubject)
    }
    
    func addRecommendationsToPlaylistOption() -> Option {
        let addToPlaylistSubject = PassthroughSubject<Void, Never>()
        
        addToPlaylistSubject
            .sink { [weak self] in
                guard let self else { return }
                self.onDidTapAddToPlaylist.send(recommendedTracks)
                withAnimation {
                    self.isOptionsSheetPresented = false
                }
            }
            .store(in: &cancellables)
        
        return Option.addToPlaylist(action: addToPlaylistSubject)
    }
    
    func addToQueueOption(_ track: Track) -> Option {
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
        
        return Option.addToQueue(action: addToQueueSubject)
    }
    
    func addTrackToSpotifyQueueOption(_ track: Track) -> Option {
        let addToQueueSubject = PassthroughSubject<Void, Never>()
        
        addToQueueSubject
            .sink { [weak self] in
                guard let self else { return }
                self.addTracksToSpotifyQueue(track)
            }
            .store(in: &cancellables)
        
        return Option.addToSpotifyQueue(action: addToQueueSubject)
    }
    
    func viewArtistOption(_ track: Track) -> Option {
        let viewArtistSubject = PassthroughSubject<Void, Never>()
        
        viewArtistSubject
            .sink { [weak self] in
                withAnimation {
                    self?.isOptionsSheetPresented = false
                }
                self?.onDidTapArtistButton.send(track.artists[.zero])
            }
            .store(in: &cancellables)
        
        return Option.viewArtist(action: viewArtistSubject)
    }
    
    func viewAlbumOption(_ track: Track) -> Option {
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
        
        return Option.viewAlbum(action: viewAlbumSubject)
    }
    
    func addToPlaylistOption(_ track: Track) -> Option {
        let addToPlaylistSubject = PassthroughSubject<Void, Never>()
        
        addToPlaylistSubject
            .sink { [weak self] in
                self?.onDidTapAddToPlaylist.send([track])
                withAnimation {
                    self?.isOptionsSheetPresented = false
                }
            }
            .store(in: &cancellables)
        
        return Option.addToPlaylist(action: addToPlaylistSubject)
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
                if let self,
                   self.hasAnySeeds {
                    self.discover()
                }
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
        if savedTracksCount > 1 {
            switch randomSeedCategory {
            case .artists:
                (0..<5).forEach { _ in
                    musicDetailsService.getSavedTracks(limit: 1, offset: Int.random(in: (1...savedTracksCount)))
                        .sink { [weak self] response in
                            guard let self else { return }
                            if let artist = response.items.map(\.track).first?.artists.first,
                               !self.seedArtists.contains(artist) {
                                withAnimation {
                                    self.seedArtists.append(artist)
                                }
                            }
                        }
                        .store(in: &cancellables)
                }
            case .tracks:
                (0..<5).forEach { _ in
                    musicDetailsService.getSavedTracks(limit: 1, offset: Int.random(in: (1...savedTracksCount)))
                        .sink { [weak self] response in
                            if let track = response.items.map(\.track).first {
                                withAnimation {
                                    self?.seedTracks.append(track)
                                }
                            }
                        }
                        .store(in: &cancellables)
                }
            default: break
            }
        }
    }
    
    func discover(limit: Int? = nil) {
        if limit == nil {
            recommendedTracks.removeAll()
            recommendedTracksBuffer.removeAll()
        }
        discoverService.discover(seedParameters: createDiscoverQueryParameters(limit: limit))
            .sink { [weak self] result in
                self?.checkIfNotAlreadySaved(tracks: result.tracks)
            }
            .store(in: &cancellables)
    }
    
    func checkIfNotAlreadySaved(tracks: [Track]) {
        musicDetailsService.checkSavedTracks(with: tracks.map(\.id).joined(separator: ","))
            .sink { [weak self] alreadySavedArray in
                guard let self else { return }
                self.recommendedTracksBuffer += alreadySavedArray.enumerated()
                    .compactMap { $0.element ? nil : tracks[$0.offset] }
                if alreadySavedArray.contains(true) {
                    let limit = alreadySavedArray.reduce(0, { initialResult, alreadySavedValue in
                        let value = alreadySavedValue ? 1 : 0
                        return initialResult + value
                    })
                    self.discover(limit: limit)
                } else {
                    withAnimation {
                        self.recommendedTracks = self.recommendedTracksBuffer
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func resetSeeds() {
        seedArtists = []
        seedTracks = []
        seedGenres = []
    }
    
    func createDiscoverQueryParameters(limit: Int? = nil) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "market", value: "HR"),
            URLQueryItem(name: "limit", value:  "\(limit ?? Int(self.limit))"),
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
    
    func addTracksToSpotifyQueue(_ track: Track? = nil) {
        if let track {
            musicDetailsService.addTracksToQueue(track.uri)
                .sink { [weak self] in
                    self?.toastMessage = "\(track.name) \(String.Shared.addedToSpotifyQueue)"
                    withAnimation {
                        self?.isToastPresented = true
                    }
                }
                .store(in: &cancellables)
        } else {
            Publishers.MergeMany(recommendedTracks.map(\.uri).map(musicDetailsService.addTracksToQueue))
                .sink {_ in
                    print("All tracks to queue.")
                }
                .store(in: &cancellables)
        }
        
    }
}
