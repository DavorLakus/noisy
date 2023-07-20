//
//  SearchViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI
import Combine

enum SearchFilterOption: Identifiable, CaseIterable {
    case artist
    case track
    case album
    case playlist
    
    var id: String {
        String(describing: self)
    }
}

final class SearchViewModel: ObservableObject {
    
    // MARK: - Coordinator actions
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    var onDidSelectTrackRow: PassthroughSubject<Track, Never>?
    let onDidTapArtistRow = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumRow = PassthroughSubject<Album, Never>()
    let onDidTapPlaylistRow = PassthroughSubject<Playlist, Never>()
    
    // MARK: - Published properties
    @Published var searchIsActive = false
    @Published var query = String.empty
    @Published var isFilterPresented: Bool = false
    @Published var isSortPresented: Bool = false
    @Published var searchLimit = 10.0
    @Published var filteringOptions: [String] = SearchFilterOption.allCases.map(\.id)
    @Published var tracks: [Track] = []
    @Published var artists: [Artist] = []
    @Published var albums: [Album] = []
    @Published var playlists: [Playlist] = []
    @Published var state: AppState = .loaded
    
    // MARK: - Public properties
    var profile: Profile? {
        guard let profile  = UserDefaults.standard.object(forKey: .Login.profile) as? Data
        else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: profile)
    }
    var noData: Bool {
        searchIsActive && !query.isEmpty
    }

    // MARK: - Private properties
    private var tracksOffset = 0
    private var albumsOffset = 0
    private var artistsOffset = 0
    private var playlistsOffset = 0
    private let searchService: SearchService
    private let filteringOptionsSelected = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class llifecycle
    init(searchService: SearchService) {
        self.searchService = searchService
        
        bindSearch()
        bindFiltering()
    }
}

// MARK: - Private extension
private extension SearchViewModel {
    
    func bindSearch() {
        $searchIsActive
            .dropFirst()
            .sink { [weak self] isActive in
                if isActive {
                    self?.reloadResults(searchActivated: true)
                } else {
                    self?.query = .empty
                    self?.resetResults()
                }
            }
            .store(in: &cancellables)
        
        $query
            .dropFirst()
            .flatMap { [weak self] in
                self?.state = .loading
                return Just($0)
            }
            .debounce(for: .seconds(0.4), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation {
                    self?.reloadResults()
                }
            }
            .store(in: &cancellables)
        
        $searchLimit
            .dropFirst()
            .debounce(for: .seconds(0.4), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation {
                    self?.reloadResults()
                }
            }
            .store(in: &cancellables)

    }
    
    func bindFiltering() {
        filteringOptionsSelected
            .sink { [weak self]  in
                withAnimation {
                    self?.resetResults()
                    self?.reloadResults()
                }
            }
            .store(in: &cancellables)
    }
    
    func reloadResults(searchActivated: Bool = false) {
        if !query.isEmpty {
            searchService.search(for: query, type: filteringOptions.joined(separator: ","), limit: Int(searchLimit), offset: .zero)
                .sink { [weak self] searchResult in
                    if let tracksResponse = searchResult.tracks {
                        self?.tracks = tracksResponse.items
                    }
                    if let albumsResponse = searchResult.albums {
                        self?.albums = albumsResponse.items
                    }
                    if let artistsResponse = searchResult.artists {
                        self?.artists = artistsResponse.items
                    }
                    if let playlistsResponse = searchResult.playlists {
                        self?.playlists = playlistsResponse.items
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func resetResults() {
        tracks = []
        artists = []
        albums = []
        playlists = []
    }
}

// MARK: - Public extensions
extension SearchViewModel {
    @Sendable
    func pullToRefresh() {
        reloadResults()
    }
    
    func profileButtonTapped() {
        onDidTapProfileButton.send()
    }
    
    func filterButtonTapped() {
        isFilterPresented.toggle()
    }
    
    func sortingButtonTapped() {
        isSortPresented.toggle()
    }
    
    func filteringOptionSelected(_ option: String) {
        if filteringOptions.contains(option) {
            filteringOptions.removeAll(where: { $0 == option })
        } else {
            filteringOptions.append(option)
        }
        filteringOptionsSelected.send()
    }
    
    func trackRowSelected(_ track: Track) {
        onDidSelectTrackRow?.send(track)
    }
    
    func albumRowSelected(_ album: Album) {
        onDidTapAlbumRow.send(album)
    }
    
    func artistRowSelected(_ artist: Artist) {
        onDidTapArtistRow.send(artist)
    }
    
    func playlistRowSelected(_ playlist: Playlist) {
        onDidTapPlaylistRow.send(playlist)
    }
}
