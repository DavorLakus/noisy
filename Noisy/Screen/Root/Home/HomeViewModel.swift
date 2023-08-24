//
//  HomeViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine
import SwiftUI

struct HomeStats {
    let title: String
    let count: Int
}

enum TimeRange: Hashable, CaseIterable {
    case shortTerm
    case mediumTerm
    case longTerm 
    
    var displayName: String {
        switch self {
        case .shortTerm:
            return "Last month"
        case .mediumTerm:
            return "Last six months"
        case .longTerm:
            return "All time"
        }
    }
    
    var codingKey: String {
        switch self {
        case .shortTerm:
            return "short_term"
        case .mediumTerm:
            return "medium_term"
        case .longTerm:
            return "long_term"
        }
    }
}

final class HomeViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var profile: Profile?
    @Published var recentlyPlayedTracks: [PlayHistoricObject] = []
    @Published var topTracks: [Track] = []
    @Published var topArtists: [Artist] = []
    @Published var playlists: [Playlist] = []
    @Published var isRecentlyPlayedSectionExpanded = false
    @Published var isTopTracksExpanded = false
    @Published var isTopArtistsExpanded = false
    @Published var isPlaylistsExpanded =  false
    @Published var topTracksTimeRange: TimeRange = .shortTerm
    @Published var topArtistsTimeRange: TimeRange = .shortTerm
    @Published var recentlyPlayedLimit: Double = 10
    @Published var topTracksLimit: Double = 10
    @Published var topArtistsLimit: Double = 10
    @Published var playlistsLimit: Double = 10
    @Published var nextRecentlyPlayedUrl: String?
    @Published var isOptionsSheetPresented = false
    @Published var isToastPresented = false
    
    // MARK: - Coordinator actions
    var tokenDidRefresh: PassthroughSubject<Void, Never>?
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    var onDidSelectTrackRow: PassthroughSubject<Void, Never>?
    let onDidTapArtistRow = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumButton = PassthroughSubject<Album, Never>()
    let onDidTapPlaylistRow = PassthroughSubject<Playlist, Never>()
    
    // MARK: - Public properties
    var options: [Option] = []
    var toastMessage: String = .empty

    // MARK: - Private properties
    
    private let homeService: HomeService
    private let queueManager: QueueManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Class lifecycle
    init(homeService: HomeService, queueManager: QueueManager) {
        self.homeService = homeService
        self.queueManager = queueManager
    }
}

// MARK: - Public extension
extension HomeViewModel {
    
    @Sendable
    func viewDidAppear() {
        cancellables.removeAll()
        bind()
        getRecentlyPlayed()
        getProfile()
        getTopTracks()
        getTopArtists()
    }
    
    func profileButtonTapped() {
        onDidTapProfileButton.send()
    }
    
    func loadMoreTapped() {
        getNextRecentlyPlayed()
    }
    
    func topTracksTapped() {
        withAnimation {
            isTopTracksExpanded.toggle()
        }
    }
    
    func topArtistsTapped() {
        withAnimation {
            isTopArtistsExpanded.toggle()
        }
    }
    
    func trackRowSelected(for track: Track) {
        queueManager.setState(with: topTracks, currentTrackIndex: topTracks.firstIndex(of: track))
        onDidSelectTrackRow?.send()
    }
    
    func artistRowSelected(for artist: Artist) {
        onDidTapArtistRow.send(artist)
    }
    
    func playlistRowSelected(for playlist: Playlist) {
        onDidTapPlaylistRow.send(playlist)
    }
    
    func trackOptionsTapped(for track: Track) {
        options = [addToQueueOption(track), viewAlbumOption(track), viewArtistOption(track)]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
}

// MARK: - Track options
private extension HomeViewModel {
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
    
    func viewArtistOption(_ track: Track) -> Option {
        let viewArtistSubject = PassthroughSubject<Void, Never>()
        
        viewArtistSubject
            .sink { [weak self] in
                withAnimation {
                    self?.isOptionsSheetPresented = false
                }
                self?.onDidTapArtistRow.send(track.artists[.zero])
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
}

// MARK: - Private extension
private extension HomeViewModel {
    func bind() {
        $topTracksTimeRange
            .dropFirst()
            .sink { [weak self] timeRange in
                self?.getTopTracks(for: timeRange)
            }
            .store(in: &cancellables)
        
        $topArtistsTimeRange
            .dropFirst()
            .sink { [weak self] timeRange in
                self?.getTopArtists(for: timeRange)
            }
            .store(in: &cancellables)
        
        $recentlyPlayedLimit
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.getRecentlyPlayed()
            }
            .store(in: &cancellables)
        
        $topTracksLimit
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.getTopTracks()
            }
            .store(in: &cancellables)
        
        $topArtistsLimit
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.getTopArtists()
            }
            .store(in: &cancellables)
        
        $playlistsLimit
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.getPlaylists()
            }
            .store(in: &cancellables)
        
        tokenDidRefresh?
            .sink { [weak self] in
                self?.viewDidAppear()
            }
            .store(in: &cancellables)
    }
    
    func getRecentlyPlayed() {
        homeService.getRecentlyPlayed(limit: Int(recentlyPlayedLimit))
            .sink { [weak self] response in
                guard let self else { return }
                self.nextRecentlyPlayedUrl = response.next
                self.recentlyPlayedTracks = response.items
            }
            .store(in: &cancellables)
    }
    
    func getNextRecentlyPlayed() {
        if let nextURL = nextRecentlyPlayedUrl {
            homeService.getNextRecentlyPlayed(url: nextURL)
                .sink { [weak self] response in
                    guard let self else { return }
                    self.nextRecentlyPlayedUrl = response.next
                    self.recentlyPlayedTracks += response.items
                    self.recentlyPlayedTracks.sort { first, second in
                        first.playedAt > second.playedAt
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func getProfile() {
        homeService.getProfile()
            .sink { [weak self] profile in
                self?.profile = profile
                
                if let profile = try? JSONEncoder().encode(profile) {
                    UserDefaults.standard.set(profile, forKey: .Login.profile)
                }
                
                self?.getPlaylists()
            }
            .store(in: &cancellables)
        
    }
    
    func getTopTracks(for timeRange: TimeRange = .shortTerm) {
        homeService.getTopTracks(count: Int(topTracksLimit), timeRange: timeRange != topTracksTimeRange ? timeRange : topTracksTimeRange)
            .sink { [weak self] tracksResponse in
                withAnimation {
                    self?.topTracks = tracksResponse.items
                }
            }
            .store(in: &cancellables)
    }
    
    func getTopArtists(for timeRange: TimeRange = .shortTerm) {
        homeService.getTopArtists(count: Int(topArtistsLimit), timeRange: timeRange != topArtistsTimeRange ? timeRange : topArtistsTimeRange)
            .sink { [weak self] artistsResponse in
                withAnimation {
                    self?.topArtists = artistsResponse.items
                }
            }
            .store(in: &cancellables)
    }
    
    func getPlaylists() {
        homeService.getMyPlaylists(count: Int(playlistsLimit))
            .sink { [weak self] playlistsResponse in
                withAnimation {
                    self?.playlists = playlistsResponse.items
                }
            }
            .store(in: &cancellables)
    }
}
