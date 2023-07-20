//
//  NoisyService.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation
import Combine

protocol NoisyAPIProtocol {
    func getAuthURL(verifier: String) -> URL
    func postToken(verifier: String, code: String) -> AnyPublisher<Data, Error>
    func postRefreshToken(with refreshToken: String) -> AnyPublisher<Data, Error>
    func getProfile() -> AnyPublisher<Data, Error>
    func getMyTopTracks(count: Int, timeRange: String) -> AnyPublisher<Data, Error>
    func getTopTracks(for artistId: String) -> AnyPublisher<Data, Error>
    func getTopArtists(count: Int, timeRange: String) -> AnyPublisher<Data, Error>
    func getPlaylists(for userId: String, count: Int) -> AnyPublisher<Data, Error>
    func getPlaylist(for playlistId: String) -> AnyPublisher<Data, Error>
    func getAlbum(with albumId: String) -> AnyPublisher<Data, Error>
    func getArtistsAlbums(for artistId: String) -> AnyPublisher<Data, Error>
    func getArtistsRelatedArtists(for artistId: String) -> AnyPublisher<Data, Error>
    func search(for query: String, type: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error>
    func discover(request: DiscoverRequest) -> AnyPublisher<Data, Error>
    func getRecommendationGenres() -> AnyPublisher<Data, Error>
}

final class NoisyService: NoisyAPIProtocol {
    
    // MARK: - Class lifecycle
    init() { }
}

// MARK: - Auth
extension NoisyService {
    func getAuthURL(verifier: String) -> URL {
        NoisyHTTPRouter.authorize(codeChallenge: NoisyCrypto.generateCodeChallenge(randomString: verifier)).url
    }
    
    func postToken(verifier: String, code: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.token(verifier: verifier, code: code))
    }
    
    func postRefreshToken(with refreshToken: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.refreshToken(refreshToken: refreshToken))
    }
}

// MARK: - Main
extension NoisyService {
    func getProfile() -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.profile)
    }

    func search(for query: String, type: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.search(query: query, type: type, limit: limit, offset: offset))
    }
    
    func getMyTopTracks(count: Int, timeRange: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.myTop(type: "tracks", count: count, timeRange: timeRange))
    }
    
    func getTopTracks(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.artistsTopTracks(artistId: artistId))
    }
    
    func getTopArtists(count: Int, timeRange: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.myTop(type: "artists", count: count, timeRange: timeRange))
    }
    
    func getPlaylists(for userId: String, count: Int) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.playlists(userId: userId, count: count))
    }
    
    func getPlaylist(for playlistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.playlist(playlistId: playlistId))
    }
    
    func getAlbum(with albumId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.album(albumId: albumId))
    }
    
    func getArtistsAlbums(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.artistsAlbums(artistId: artistId))
    }
    
    func getArtistsRelatedArtists(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.artistsRelatedArtists(artistId: artistId))
    }
    
    func discover(request: DiscoverRequest) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.recommendation(request: request))
    }
    
    func getRecommendationGenres() -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.recommendationGenres)
    }
}
