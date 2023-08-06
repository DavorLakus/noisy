//
//  NoisyHTTPRouter.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation

enum NoisyHTTPRouter {
    case authorize(codeChallenge: String)
    case token(verifier: String, code: String)
    case refreshToken(refreshToken: String)
    case profile
    case myTop(type: String, count: Int, timeRange: String)
    case track(id: String)
    case artist(artistId: String)
    case album(albumId: String)
    case albumTracks(albumId: String, limit: Int, offset: Int)
    case playlist(playlistId: String)
    case playlistTracks(playlistId: String, limit: Int, offset: Int)
    case playlists(userId: String, count: Int)
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
        case .profile, .myTop, .track, .playlists, .artist, .playlist, .playlistTracks, .album, .albumTracks, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists, .search, .recommendation, .recommendationGenres:
            return "api.spotify.com"
        }
    }
    
    public var basePath: String {
        switch self {
        case .authorize:
            return .empty
        case .token, .refreshToken:
            return "/api"
        case .profile, .myTop, .track, .playlists, .artist, .playlist, .playlistTracks, .album, .albumTracks, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists, .search, .recommendation, .recommendationGenres:
            return "/v1"
        }
    }
    
    public var path: String {
        switch self {
        case .authorize:
            return "/authorize"
        case .profile:
            return "/me"
        case .search:
            return "/search"
        case .track(let id):
            return "/tracks/\(id)"
        case .recommendation:
            return "/recommendations"
        case .recommendationGenres:
            return "/recommendations/available-genre-seeds"
        case .token, .refreshToken:
            return "/token"
        case .myTop(let type, _, _):
            return "/me/top/\(type)"
        case .playlists(let id, _):
            return "/users/\(id)/playlists"
        case .album(let id):
            return "/albums/\(id)"
        case .albumTracks(let id, _, _):
            return "/albums/\(id)/tracks"
        case .playlist(let id):
            return "/playlists/\(id)"
        case .playlistTracks(let id, _, _):
            return "/playlists/\(id)/tracks"
        case .artist(let id):
            return "/artists/\(id)"
        case .artistsAlbums(let artistId):
            return "/artists/\(artistId)/albums"
        case .artistsTopTracks(let artistId):
            return "/artists/\(artistId)/top-tracks"
        case .artistsRelatedArtists(let artistId):
            return "/artists/\(artistId)/related-artists"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .profile, .search, .recommendation, .recommendationGenres, .authorize, .myTop, .track, .playlists, .artist, .playlist, .playlistTracks, .album, .albumTracks, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists:
            return .get
        case .token, .refreshToken:
            return .post
        }
    }
    
    public var headers: [String : Any]? {
        switch self {
        case .authorize:
            return nil
        case .profile, .search, .recommendation, .recommendationGenres, .myTop, .track, .playlists, .artist, .playlist, .playlistTracks, .album, .albumTracks, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists:
            return authToken
        case .token, .refreshToken:
            return ["Content-Type" : "application/x-www-form-urlencoded"]
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
        case .search(let query, let type, let limit, let offset):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "type", value: type),
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "market", value: "HR")
            ]
        case .myTop(_, let count, let timeRange):
            return [
                URLQueryItem(name: "limit", value: "\(count)"),
                URLQueryItem(name: "time_range", value: "\(timeRange)")
            ]
        case .playlists(_, let count):
            return [URLQueryItem(name: "limit", value: "\(count)")]
        case .playlistTracks(_, let limit, let offset), .albumTracks(_, let limit, let offset):
            return [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        case .artistsTopTracks:
            return [URLQueryItem(name: "market", value: "HR")]
        case .profile, .track, .artist, .playlist, .playlistTracks, .album, .albumTracks, .artistsAlbums, .artistsRelatedArtists, .recommendationGenres:
            return nil
        case .recommendation(let parameters):
            return parameters
        }
    }
}
