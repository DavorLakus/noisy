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
    func getTrack(with id: String) -> PassthroughSubject<Track, Never> {
        let track = PassthroughSubject<Track, Never>()
        
        api.getTrack(with: id)
            .decode(type: Track.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    track.send(result)
                })
            .store(in: &cancellables)
        
        return track
    }
    
    func getSavedTracks(limit: Int, offset: Int) -> PassthroughSubject<TrackObjectsResponse, Never> {
        let savedTracks = PassthroughSubject<TrackObjectsResponse, Never>()
        
        api.getSavedTracks(limit: limit, offset: offset)
            .decode(type: TrackObjectsResponse.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    savedTracks.send(result)
                })
            .store(in: &cancellables)
        
        return savedTracks
    }
    
    func checkSavedTracks(with ids: String) -> PassthroughSubject<[Bool], Never> {
        let tracksSavedStatus = PassthroughSubject<[Bool], Never>()
        
        api.checkSavedTracks(trackIds: ids)
            .decode(type: [Bool].self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    tracksSavedStatus.send(result)
                })
            .store(in: &cancellables)
        
        return tracksSavedStatus
    }
    
    func saveTracks(with ids: String) -> PassthroughSubject<Void, Never> {
        let tracksSaved = PassthroughSubject<Void, Never>()
        
        api.saveTracks(with: ids)
            .decode(type: Dictionary<String, String>.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { completion in
                    tracksSaved.send()
                },
                receiveValue: { _ in
                    
                })
            .store(in: &cancellables)
        
        return tracksSaved
    }
    
    func removeTracks(with ids: String) -> PassthroughSubject<Void, Never> {
        let tracksRemoved = PassthroughSubject<Void, Never>()
        
        api.removeTracks(with: ids)
            .decode(type: Dictionary<String, String>.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { _ in
                    tracksRemoved.send()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        return tracksRemoved
    }
    
    func getArtistsTopTracks(for artistId: String) -> PassthroughSubject<[Track], Never> {
        let topTracks = PassthroughSubject<[Track], Never>()
        
        api.getTopTracks(for: artistId)
            .decode(type: Tracks.self, decoder: JSONDecoder())
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
    
    func getPlaylists(limit: Int, offset: Int) -> PassthroughSubject<PlaylistsResponse, Never> {
        let playlists = PassthroughSubject<PlaylistsResponse, Never>()
        
        if let profileData  = UserDefaults.standard.object(forKey: .Login.profile) as? Data,
           let user = try? JSONDecoder().decode(Profile.self, from: profileData) {
            api.getPlaylists(for: user.id, limit: limit, offset: offset)
                .decode(type: PlaylistsResponse.self, decoder: JSONDecoder())
                .sink(
                    receiveCompletion: NetworkingManager.handleCompletion,
                    receiveValue: { result in
                        playlists.send(result)
                    })
                .store(in: &cancellables)
        }
        
        return playlists
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
    
    func addTracksToPlaylist(_ playlistId: String, tracks: String) -> PassthroughSubject<Void, Never> {
        let tracksAdded = PassthroughSubject<Void, Never>()

        api.addTracksToPlaylist(playlistId, tracks: tracks)
            .decode(type: SpotifyError.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { completion in
                    tracksAdded.send()
                },
                receiveValue: { error in
                    print(error)
                })
            .store(in: &cancellables)
        
        return tracksAdded
    }
    
    func createNewPlaylist(_ name: String) -> PassthroughSubject<Playlist, Never> {
        let playlistCreated = PassthroughSubject<Playlist, Never>()

        if let profileData  = UserDefaults.standard.object(forKey: .Login.profile) as? Data,
           let user = try? JSONDecoder().decode(Profile.self, from: profileData) {
            api.createNewPlaylist(userId: user.id, name: name)
                .decode(type: Playlist.self, decoder: JSONDecoder())
                .sink(
                    receiveCompletion: NetworkingManager.handleCompletion,
                    receiveValue: { result in
                        playlistCreated.send(result)
                    })
                .store(in: &cancellables)
        }
        
        return playlistCreated
    }
    
    func getArtist(with artistId: String) -> PassthroughSubject<Artist, Never> {
        let artist = PassthroughSubject<Artist, Never>()
        
        api.getArtist(with: artistId)
            .decode(type: Artist.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { result in
                    artist.send(result)
                })
            .store(in: &cancellables)
        
        return artist
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
