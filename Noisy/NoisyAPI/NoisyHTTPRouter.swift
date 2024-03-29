//
//  NoisyHTTPRouter.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation

struct CreatePlaylistModel: Codable {
    let name: String
}

enum NoisyHTTPRouter {
    case url(String)
    case authorize(codeChallenge: String)
    case token(verifier: String, code: String)
    case refreshToken(refreshToken: String)
    case profile
    case getDevices
    case recentlyPlayed(limit: Int)
    case myTop(type: String, count: Int, timeRange: String)
    case track(id: String)
    case trackAudioFeatures(ids: String)
    case savedTracks(limit: Int, offset: Int)
    case checkSavedTracks(ids: String)
    case saveTracks(ids: String)
    case removeTracks(ids: String)
    case artist(artistId: String)
    case album(albumId: String)
    case albumTracks(albumId: String, limit: Int, offset: Int)
    case playlist(playlistId: String)
    case playlistTracks(playlistId: String, limit: Int, offset: Int)
    case playlists(userId: String, limit: Int, offset: Int)
    case addToQueue(trackUri: String)
    case createPlaylist(userId: String, name: String)
    case addToPlaylist(playlistId: String, uris: String)
    case artistsTopTracks(artistId: String)
    case artistsAlbums(artistId: String)
    case artistsRelatedArtists(artistId: String)
    case search(query: String, type: String, limit: Int, offset: Int)
    case recommendation(parameters: [URLQueryItem])
    case recommendationGenres
}

extension NoisyHTTPRouter: APIEndpoint {
    public var baseURL: String {
        switch self {
        case .authorize, .token, .refreshToken:
            return "accounts.spotify.com"
        case .profile, .recentlyPlayed, .getDevices, .myTop, .track, .trackAudioFeatures, .savedTracks, .checkSavedTracks, .saveTracks, .removeTracks, .playlists, .artist, .playlist, .playlistTracks, .addToQueue, .createPlaylist, .addToPlaylist, .album, .albumTracks, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists, .search, .recommendation, .recommendationGenres:
            return "api.spotify.com"
        case .url(let url):
            return url
        }
    }
    
    public var basePath: String {
        switch self {
        case .authorize:
            return .empty
        case .token, .refreshToken:
            return "/api"
        case .profile, .recentlyPlayed, .getDevices, .myTop, .track, .trackAudioFeatures, .savedTracks, .checkSavedTracks, .saveTracks, .removeTracks, .playlists, .artist, .playlist, .playlistTracks, .addToQueue, .createPlaylist, .addToPlaylist, .album, .albumTracks, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists, .search, .recommendation, .recommendationGenres:
            return "/v1"
        case .url:
            return .empty
        }
    }
    
    public var path: String {
        switch self {
        case .authorize:
            return "/authorize"
        case .profile:
            return "/me"
        case .recentlyPlayed:
            return "/me/player/recently-played"
        case .getDevices:
            return "/me/player/devices"
        case .search:
            return "/search"
        case .track(let id):
            return "/tracks/\(id)"
        case .trackAudioFeatures:
            return "/audio-features"
        case .checkSavedTracks:
            return "/me/tracks/contains"
        case .saveTracks, .savedTracks:
            return "/me/tracks"
        case .removeTracks:
            return "/me/tracks"
        case .recommendation:
            return "/recommendations"
        case .recommendationGenres:
            return "/recommendations/available-genre-seeds"
        case .token, .refreshToken:
            return "/token"
        case .myTop(let type, _, _):
            return "/me/top/\(type)"
        case .playlists(let id, _, _):
            return "/users/\(id)/playlists"
        case .album(let id):
            return "/albums/\(id)"
        case .albumTracks(let id, _, _):
            return "/albums/\(id)/tracks"
        case .playlist(let id):
            return "/playlists/\(id)"
        case .playlistTracks(let id, _, _):
            return "/playlists/\(id)/tracks"
        case .addToQueue:
            return "/me/player/queue"
        case .createPlaylist(let id, _):
            return "/users/\(id)/playlists"
        case .addToPlaylist(let id, _):
            return "/playlists/\(id)/tracks"
        case .artist(let id):
            return "/artists/\(id)"
        case .artistsAlbums(let artistId):
            return "/artists/\(artistId)/albums"
        case .artistsTopTracks(let artistId):
            return "/artists/\(artistId)/top-tracks"
        case .artistsRelatedArtists(let artistId):
            return "/artists/\(artistId)/related-artists"
        case .url:
            return .empty
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .url, .profile, .recentlyPlayed, .getDevices, .search, .recommendation, .recommendationGenres, .authorize, .myTop, .track, .trackAudioFeatures, .savedTracks, .checkSavedTracks, .playlists, .artist, .playlist, .playlistTracks, .album, .albumTracks, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists:
            return .get
        case .token, .refreshToken, .addToQueue, .createPlaylist, .addToPlaylist:
            return .post
        case .saveTracks:
            return .put
        case .removeTracks:
            return .delete
        }
    }
    
    public var headers: [String : Any]? {
        switch self {
        case .authorize:
            return nil
        case .url, .profile, .recentlyPlayed, .getDevices, .search, .recommendation, .recommendationGenres, .myTop, .track, .trackAudioFeatures, .savedTracks, .checkSavedTracks, .saveTracks, .removeTracks, .playlists, .artist, .playlist, .playlistTracks, .createPlaylist, .addToQueue, .addToPlaylist, .album, .albumTracks, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists:
            return authToken
        case .token, .refreshToken:
            return ["Content-Type" : "application/x-www-form-urlencoded"]
        }
    }
    
    public func body() throws -> Data? {
        switch self {
        case .createPlaylist(_, let name):
            print("name: \(name)")
            if let json = try? CreatePlaylistModel(name: name).toJSON() {
                print(json)
            }
            return try CreatePlaylistModel(name: name).toJSON()
        default:
            return nil
        }
    }
    
    public var parameters: [URLQueryItem]? {
        switch self {
        case .authorize(let challenge):
            return [
                URLQueryItem(name:"response_type", value: "code"),
                URLQueryItem(name:"client_id", value: APIConstants.clientID),
                URLQueryItem(name:"redirect_uri", value: "https://github.com/DavorLakus/noisy"),
                URLQueryItem(name:"code_challenge_method", value: "S256"),
                URLQueryItem(name: "scope", value: Scope.allCases.map(\.rawValue).reduce(.empty, {"\($0!) \($1)"})),
                URLQueryItem(name:"code_challenge", value: challenge)
            ]
        case .token(let verifier, let code):
            return [
                URLQueryItem(name:"grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name:"redirect_uri", value: "https://github.com/DavorLakus/noisy"),
                URLQueryItem(name:"client_id", value: APIConstants.clientID),
                URLQueryItem(name:"code_verifier", value: verifier)
            ]
        case .refreshToken(let refreshToken):
            return [
                URLQueryItem(name:"grant_type", value: "refresh_token"),
                URLQueryItem(name:"refresh_token", value: refreshToken),
                URLQueryItem(name:"client_id", value: APIConstants.clientID)
            ]
        case .recentlyPlayed(let limit):
            return [
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        case .trackAudioFeatures(let ids):
            return [
                URLQueryItem(name: "ids", value: ids)
            ]
        case .savedTracks(let limit, let offset):
            return [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "market", value: "HR")
            ]
        case .checkSavedTracks(ids: let ids), .saveTracks(ids: let ids), .removeTracks(ids: let ids):
            return [
                URLQueryItem(name: "ids", value: ids)
            ]
        case .search(let query, let type, let limit, let offset):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "type", value: type),
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "market", value: "HR")
            ]
        case .playlists(_, let limit, let offset):
            return [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        case .playlistTracks(_, let limit, let offset), .albumTracks(_, let limit, let offset):
            return [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        case .addToQueue(let trackUri):
            return [
                URLQueryItem(name: "uri", value: "\(trackUri)")
            ]
        case .addToPlaylist(_, let uris):
            return [
                URLQueryItem(name: "uris", value: "\(uris)")
            ]
        case .artistsTopTracks:
            return [URLQueryItem(name: "market", value: "HR")]
        case .recommendation(let parameters):
            return parameters
        case .myTop(_, let count, let timeRange):
            return [
                URLQueryItem(name: "limit", value: "\(count)"),
                URLQueryItem(name: "time_range", value: "\(timeRange)")
            ]
        case .url, .profile, .getDevices, .track, .artist, .playlist, .createPlaylist, .album, .artistsAlbums, .artistsRelatedArtists, .recommendationGenres:
            return nil
        }
    }
    
    public var url: URL {
        if case .url(let string) = self {
            return URL(string: string)!
        } else {
            var components = URLComponents()
            components.scheme = "https"
            components.host = baseURL
            components.path = basePath + path
            components.queryItems = parameters
            
            guard let url = components.url else {
                preconditionFailure("Invalid URL components: \(components)")
            }
            
            return url
        }
    }
    
    var request: URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = method.description
        request.httpBody = try? body()

        headers?.forEach { (key, value) in
            request.addValue(value as! String, forHTTPHeaderField: key)
        }
        
        return request
    }
}
