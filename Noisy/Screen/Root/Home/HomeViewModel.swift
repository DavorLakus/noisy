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
    @Published var topTracks: [Track] = []
    @Published var topArtists: [Artist] = []
    @Published var playlists: [Playlist] = []
    @Published var isTopTracksExpanded = false
    @Published var isTopArtistsExpanded = false
    @Published var isPlaylistsExpanded =  false
    @Published var topTracksTimeRange: TimeRange = .shortTerm
    @Published var topArtistsTimeRange: TimeRange = .shortTerm
    @Published var topTracksCount: Double = 10
    @Published var topArtistsCount: Double = 10
    @Published var playlistsCount: Double = 10

    // MARK: - Coordinator actions
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    var onDidSelectTrackRow: PassthroughSubject<Track, Never>?
    let onDidTapArtistRow = PassthroughSubject<Artist, Never>()
    let onDidTapPlaylistRow = PassthroughSubject<Playlist, Never>()

    // MARK: - Private properties
    private let homeService: HomeService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Class lifecycle
    init(homeService: HomeService) {
        self.homeService = homeService
        bind()
    }
}

// MARK: - Public extension
extension HomeViewModel {
    
    @Sendable
    func viewDidAppear() {
        getProfile()
        getTopTracks()
        getTopArtists()
    }
    
    func profileButtonTapped() {
        onDidTapProfileButton.send()
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
        onDidSelectTrackRow?.send(track)
    }
    
    func artistRowSelected(for artist: Artist) {
        onDidTapArtistRow.send(artist)
    }
    
    func playlistRowSelected(for playlist: Playlist) {
        onDidTapPlaylistRow.send(playlist)
    }
    
    func artistOptionsTapped(for artist: Artist) {
        
    }
    
    func trackOptionsTapped(for track: Track) {
        
    }
    
    func playlistOptionsTapped(for playlist: Playlist) {
        
    }
}

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
        
        $topTracksCount
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.getTopTracks()
            }
            .store(in: &cancellables)
        
        $topArtistsCount
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.getTopArtists()
            }
            .store(in: &cancellables)
        
        $playlistsCount
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.getPlaylists()
            }
            .store(in: &cancellables)
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
        homeService.getTopTracks(count: Int(topTracksCount), timeRange: timeRange != topTracksTimeRange ? timeRange : topTracksTimeRange)
            .sink { [weak self] tracksResponse in
                withAnimation {
                    self?.topTracks = tracksResponse.items
                }
            }
            .store(in: &cancellables)
    }
    
    func getTopArtists(for timeRange: TimeRange = .shortTerm) {
        homeService.getTopArtists(count: Int(topArtistsCount), timeRange: timeRange != topArtistsTimeRange ? timeRange : topArtistsTimeRange)
            .sink { [weak self] artistsResponse in
                withAnimation {
                    self?.topArtists = artistsResponse.items
                }
            }
            .store(in: &cancellables)
    }
    
    func getPlaylists() {
        homeService.getMyPlaylists(count: Int(playlistsCount))
            .sink { [weak self] playlistsResponse in
                withAnimation {
                    self?.playlists = playlistsResponse.items
                }
            }
            .store(in: &cancellables)
    }
}
