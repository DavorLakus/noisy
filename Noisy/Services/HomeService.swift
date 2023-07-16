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
                receiveValue: { [weak self] result in
                    user.send(result)
                })
            .store(in: &cancellables)
        
        return user
    }
    
    func getTopTracks(count: Int, timeRange: TimeRange) -> PassthroughSubject<MyTopTracksResponse, Never> {
        let topTracks = PassthroughSubject<MyTopTracksResponse, Never>()
        
        api.getTopTracks(count: count, timeRange: timeRange.codingKey)
            .decode(type: MyTopTracksResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion) { response in
                topTracks.send(response)
            }
            .store(in: &cancellables)
        
        return topTracks
    }
    
    func getTopArtists(count: Int, timeRange: TimeRange) -> PassthroughSubject<MyTopArtistsResponse, Never> {
        let topTracks = PassthroughSubject<MyTopArtistsResponse, Never>()
        print(count)
        api.getTopArtists(count: count, timeRange: timeRange.codingKey)
            .decode(type: MyTopArtistsResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion) { response in
                topTracks.send(response)
            }
            .store(in: &cancellables)
        
        return topTracks
    }
}


struct MyTopArtistsResponse: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [Artist]
}

struct MyTopTracksResponse: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [Track]
}

struct Track: Codable {
    let id: String
    let name: String
    let album: Album
    let artists: [Artist]
    let durationMs: Int
    let popularity: Int
    let previewUrl: String?
    let href: String
    
    enum CodingKeys: String, CodingKey {
        case durationMs = "duration_ms"
        case previewUrl = "preview_url"
        case id, name, album, artists, popularity, href
    }
}

struct Album: Codable {
    let name: String
    let releaseDate: String
    let genres: [String]?
    let totalTracks: Int
    let popularity: Int?
    let images: [SpotifyImage]
    let href: String
    
    enum CodingKeys: String, CodingKey {
        case totalTracks = "total_tracks"
        case releaseDate = "release_date"
        case name, genres, popularity, href, images
    }
}

struct Artist: Codable {
    let id: String
    let name: String
    let href: String
    let images: [SpotifyImage]?
}
