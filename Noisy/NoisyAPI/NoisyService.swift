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
}

final class NoisyService: NoisyAPIProtocol {
    
    // MARK: - Class lifecycle
    init() { }
}

// MARK: - Auth
extension NoisyService {
    func getAuthURL(verifier: String) -> URL {
        NoisyHTTPRouter.authorize(NoisyCrypto.generateCodeChallenge(randomString: verifier)).url
    }
    
    func postToken(verifier: String, code: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.token(verifier, code))
    }
    
    func postRefreshToken(with refreshToken: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.refreshToken(refreshToken))
    }
}

// MARK: - Main
extension NoisyService {
    func getProfile() -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.profile)
    }

    func search(for query: String, type: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.search(query, type, limit, offset))
    }
    
    func getMyTopTracks(count: Int, timeRange: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.myTop("tracks", count, timeRange))
    }
    
    func getTopTracks(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.artistsTopTracks(artistId))
    }
    
    func getTopArtists(count: Int, timeRange: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.myTop("artists", count, timeRange))
    }
    
    func getPlaylists(for userId: String, count: Int) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.playlists(userId, count))
    }
    
    func getPlaylist(for playlistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.playlist(playlistId))
    }
    
    func getAlbum(with albumId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.album(albumId))
    }
    
    func getArtistsAlbums(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.artistsAlbums(artistId))
    }
    
    func getArtistsRelatedArtists(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.artistsRelatedArtists(artistId))
    }
}
