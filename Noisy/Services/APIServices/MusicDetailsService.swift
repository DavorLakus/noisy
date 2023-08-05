//
//  MusicDetailService.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import Foundation
import Combine

final class MusicDetailsService {
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    private let api: NoisyAPIProtocol
    
    // MARK: - Class lifecycle
    public init(api: NoisyAPIProtocol) {
        self.api = api
    }
}

extension MusicDetailsService {
    
    func getArtistsTopTracks(for artistId: String) -> PassthroughSubject<[Track], Never> {
        let topTracks = PassthroughSubject<[Track], Never>()
        
        api.getTopTracks(for: artistId)
            .decode(type: TracksR.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    topTracks.send(result.tracks)
                })
            .store(in: &cancellables)
        
        return topTracks
    }
    
    func getArtistsAlbums(for artistId: String) -> PassthroughSubject<[Album], Never> {
        let albums = PassthroughSubject<[Album], Never>()
        
        api.getArtistsAlbums(for: artistId)
            .decode(type: AlbumResponse.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    albums.send(result.items)
                })
            .store(in: &cancellables)
        
        return albums
    }
    
    func getArtistsRelatedArtists(for artistId: String) -> PassthroughSubject<[Artist], Never> {
        let relatedArtists = PassthroughSubject<[Artist], Never>()
        
        api.getArtistsRelatedArtists(for: artistId)
            .decode(type: RelatedArtistsResponse.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    relatedArtists.send(result.artists)
                })
            .store(in: &cancellables)
        
        return relatedArtists
    }
    
    func getPlaylist(for playlistId: String) -> PassthroughSubject<PlaylistResponse, Never> {
        let playlist = PassthroughSubject<PlaylistResponse, Never>()
        
        api.getPlaylist(with: playlistId)
            .decode(type: PlaylistResponse.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    playlist.send(result)
                })
            .store(in: &cancellables)
        
        return playlist
    }
    
    func getPlaylistTracks(for playlistId: String, limit: Int, offset: Int) -> PassthroughSubject<TrackObjectsResponse, Never> {
        let tracks = PassthroughSubject<TrackObjectsResponse, Never>()
        
        api.getPlaylistTracks(for: playlistId, limit: limit, offset: offset)
            .decode(type: TrackObjectsResponse.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    tracks.send(result)
                })
            .store(in: &cancellables)
        
        return tracks
    }
    
    func getAlbum(with albumId: String) -> PassthroughSubject<Album, Never> {
        let album = PassthroughSubject<Album, Never>()
        
        api.getAlbum(with: albumId)
            .decode(type: Album.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    album.send(result)
                })
            .store(in: &cancellables)
        
        return album
    }
    
    func getAlbumTracks(for albumId: String, limit: Int, offset: Int) -> PassthroughSubject<TracksResponse, Never> {
        let tracks = PassthroughSubject<TracksResponse, Never>()
        
        api.getAlbumTracks(for: albumId, limit: limit, offset: offset)
            .decode(type: TracksResponse.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    tracks.send(result)
                })
            .store(in: &cancellables)
        
        return tracks
    }
}
