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
    func getTrack(with id: String) -> AnyPublisher<Data, Error>
    func getTrackAudioFeatures(with ids: String) -> AnyPublisher<Data, Error>
    func getSavedTracks(limit: Int, offset: Int) -> AnyPublisher<Data, Error>
    func checkSavedTracks(trackIds: String) -> AnyPublisher<Data, Error>
    func saveTracks(with ids: String) -> AnyPublisher<Data, Error>
    func removeTracks(with id: String) -> AnyPublisher<Data, Error>
    func getMyTopTracks(count: Int, timeRange: String) -> AnyPublisher<Data, Error>
    func getTopTracks(for artistId: String) -> AnyPublisher<Data, Error>
    func getTopArtists(count: Int, timeRange: String) -> AnyPublisher<Data, Error>
    func getPlaylists(for userId: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error>
    func getPlaylist(with playlistId: String) -> AnyPublisher<Data, Error>
    func getPlaylistTracks(for playlistId: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error>
    func createNewPlaylist(userId: String, name: String) -> AnyPublisher<Data, Error>
    func addTracksToPlaylist(_ playlistId: String, tracks: String) -> AnyPublisher<Data, Error>
    func getArtist(with id: String) -> AnyPublisher<Data, Error>
    func getAlbum(with albumId: String) -> AnyPublisher<Data, Error>
    func getAlbumTracks(for albumId: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error>
    func getArtistsAlbums(for artistId: String) -> AnyPublisher<Data, Error>
    func getArtistsRelatedArtists(for artistId: String) -> AnyPublisher<Data, Error>
    func search(for query: String, type: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error>
    func discover(parameters: [URLQueryItem]) -> AnyPublisher<Data, Error>
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
        NetworkingManager.performRequest(.token(verifier: verifier, code: code))
    }
    
    func postRefreshToken(with refreshToken: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.refreshToken(refreshToken: refreshToken))
    }
}

// MARK: - Main
extension NoisyService {
    func getProfile() -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.profile)
    }

    func search(for query: String, type: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.search(query: query, type: type, limit: limit, offset: offset))
    }
    
    func getTrack(with id: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.track(id: id))
    }
    
    func getTrackAudioFeatures(with ids: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.trackAudioFeatures(ids: ids))
    }
    
    func getSavedTracks(limit: Int, offset: Int) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.savedTracks(limit: limit, offset: offset))
    }
    
    func checkSavedTracks(trackIds: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.checkSavedTracks(ids: trackIds))
    }
    
    func saveTracks(with ids: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.saveTracks(ids: ids))
    }
    
    func removeTracks(with ids: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.removeTracks(ids: ids))
    }
    
    func getMyTopTracks(count: Int, timeRange: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.myTop(type: "tracks", count: count, timeRange: timeRange))
    }
    
    func getTopTracks(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.artistsTopTracks(artistId: artistId))
    }
    
    func getTopArtists(count: Int, timeRange: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.myTop(type: "artists", count: count, timeRange: timeRange))
    }
    
    func getPlaylists(for userId: String, limit: Int, offset: Int = .zero) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.playlists(userId: userId, limit: limit, offset: offset))
    }
    
    func getPlaylist(with playlistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.playlist(playlistId: playlistId))
    }
    
    func getPlaylistTracks(for playlistId: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.playlistTracks(playlistId: playlistId, limit: limit, offset: offset))
    }
    
    func createNewPlaylist(userId: String, name: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.createPlaylist(userId: userId, name: name))
    }
    
    func addTracksToPlaylist(_ playlistId: String, tracks: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.addToPlaylist(playlistId: playlistId, uris: tracks))
    }

    func getArtist(with id: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.artist(artistId: id))
    }
    
    func getAlbum(with albumId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.album(albumId: albumId))
    }
    
    func getAlbumTracks(for albumId: String, limit: Int, offset: Int) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.albumTracks(albumId: albumId, limit: limit, offset: offset))
    }
    
    func getArtistsAlbums(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.artistsAlbums(artistId: artistId))
    }
    
    func getArtistsRelatedArtists(for artistId: String) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.artistsRelatedArtists(artistId: artistId))
    }
    
    func discover(parameters: [URLQueryItem]) -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.recommendation(parameters: parameters))
    }
    
    func getRecommendationGenres() -> AnyPublisher<Data, Error> {
        NetworkingManager.performRequest(.recommendationGenres)
    }
}
