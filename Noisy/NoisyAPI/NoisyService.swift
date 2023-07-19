//
//  NoisyService.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation
import Combine

public protocol NoisyAPIProtocol {
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

}

public final class NoisyService: NoisyAPIProtocol {
    
    // MARK: - Class lifecycle
    public init() { }
}

// MARK: - Auth
extension NoisyService {
    public func getAuthURL(verifier: String) -> URL {
        NoisyHTTPRouter.authorize(NoisyCrypto.generateCodeChallenge(randomString: verifier)).url
    }
    
    public func postToken(verifier: String, code: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.token(verifier, code))
    }
    
    public func postRefreshToken(with refreshToken: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.refreshToken(refreshToken))
    }
}

// MARK: - Main
extension NoisyService {
    public func getProfile() -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.profile)
    }

    public func getMyTopTracks(count: Int, timeRange: String) -> AnyPublisher<Data, Error> {
        return NetworkingManager.download(.myTop("tracks", count, timeRange))
    }
    
    public func getTopTracks(for artistId: String) -> AnyPublisher<Data, Error> {
        return NetworkingManager.download(.artistsTopTracks(artistId))
    }
    
    public func getTopArtists(count: Int, timeRange: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.myTop("artists", count, timeRange))
    }
    
    public func getPlaylists(for userId: String, count: Int) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.playlists(userId, count))
    }
    
    public func getPlaylist(for playlistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.playlist(playlistId))
    }
    
    public func getAlbum(with albumId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.album(albumId))
    }
    
    public func getArtistsAlbums(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.artistsAlbums(artistId))
    }
    
    public func getArtistsRelatedArtists(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.download(.artistsRelatedArtists(artistId))
    }
}
