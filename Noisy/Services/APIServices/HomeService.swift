//
//  HomeService.swift
//  Noisy
//
//  Created by Davor Lakus on 06.06.2023..
//

import Foundation
import Combine

final class HomeService {
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    private let api: NoisyAPIProtocol
    
    // MARK: - Class lifecycle
    public init(api: NoisyAPIProtocol) {
        self.api = api
    }
}

// MARK: - Public extension
extension HomeService {
    func getProfile() -> PassthroughSubject<Profile, Never> {
        let user = PassthroughSubject<Profile, Never>()
        
        api.getProfile()
            .decode(type: Profile.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    user.send(result)
                })
            .store(in: &cancellables)
        
        return user
    }
    
    func getRecentlyPlayed(limit: Int, offset: Int) -> PassthroughSubject<RecentlyPlayedResponse, Never> {
        let recentlyPlayed =  PassthroughSubject<RecentlyPlayedResponse, Never>()
        
        api.getRecentlyPlayed(limit: limit, offset: offset)
            .decode(type: RecentlyPlayedResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion) { response in
                recentlyPlayed.send(response)
            }
            .store(in: &cancellables)
        
        return recentlyPlayed
    }
    
    func getTopTracks(count: Int, timeRange: TimeRange) -> PassthroughSubject<TracksResponse, Never> {
        let topTracks = PassthroughSubject<TracksResponse, Never>()
        
        api.getMyTopTracks(count: count, timeRange: timeRange.codingKey)
            .decode(type: TracksResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion) { response in
                topTracks.send(response)
            }
            .store(in: &cancellables)
        
        return topTracks
    }
    
    func getTopArtists(count: Int, timeRange: TimeRange) -> PassthroughSubject<ArtistsResponse, Never> {
        let topTracks = PassthroughSubject<ArtistsResponse, Never>()

        api.getTopArtists(count: count, timeRange: timeRange.codingKey)
            .decode(type: ArtistsResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion) { response in
                topTracks.send(response)
            }
            .store(in: &cancellables)
        
        return topTracks
    }
    
    func getMyPlaylists(count: Int) -> PassthroughSubject<PlaylistsResponse, Never> {
        let playlists = PassthroughSubject<PlaylistsResponse, Never>()
        
        if let profileData  = UserDefaults.standard.object(forKey: .Login.profile) as? Data,
           let user = try? JSONDecoder().decode(Profile.self, from: profileData) {
            api.getPlaylists(for: user.id, limit: count, offset: .zero)
                .decode(type: PlaylistsResponse.self, decoder: JSONDecoder())
                .sink(receiveCompletion: NetworkingManager.handleCompletion) { response in
                    playlists.send(response)
                }
                .store(in: &cancellables)
        }
        
        return playlists
    }
}
