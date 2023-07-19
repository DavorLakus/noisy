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
    
    func getTopTracks(count: Int, timeRange: TimeRange) -> PassthroughSubject<Tracks, Never> {
        let topTracks = PassthroughSubject<Tracks, Never>()
        
        api.getMyTopTracks(count: count, timeRange: timeRange.codingKey)
            .decode(type: Tracks.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion) { response in
                topTracks.send(response)
            }
            .store(in: &cancellables)
        
        return topTracks
    }
    
    func getTopArtists(count: Int, timeRange: TimeRange) -> PassthroughSubject<MyTopArtistsResponse, Never> {
        let topTracks = PassthroughSubject<MyTopArtistsResponse, Never>()

        api.getTopArtists(count: count, timeRange: timeRange.codingKey)
            .decode(type: MyTopArtistsResponse.self, decoder: JSONDecoder())
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
            api.getPlaylists(for: user.id, count: count)
                .decode(type: PlaylistsResponse.self, decoder: JSONDecoder())
                .sink(receiveCompletion: NetworkingManager.handleCompletion) { response in
                    playlists.send(response)
                }
                .store(in: &cancellables)
        }
        
        return playlists
    }
}
