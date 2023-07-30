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
    case artist(artistId: String)
    case album(albumId: String)
    case playlist(playlistId: String)
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
        case .profile, .myTop, .playlists, .artist, .playlist, .album, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists, .search, .recommendation, .recommendationGenres:
            return "api.spotify.com"
        }
    }
    
    public var basePath: String {
        switch self {
        case .authorize:
            return .empty
        case .token, .refreshToken:
            return "/api"
        case .profile, .myTop, .playlists, .artist, .playlist, .album, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists, .search, .recommendation, .recommendationGenres:
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
        case .playlist(let id):
            return "/playlists/\(id)"
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
        case .profile, .search, .recommendation, .recommendationGenres, .authorize, .myTop, .playlists, .artist, .playlist, .album, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists:
            return .get
        case .token, .refreshToken:
            return .post
        }
    }
    
    public var headers: [String : Any]? {
        switch self {
        case .authorize:
            return nil
        case .profile, .search, .recommendation, .recommendationGenres, .myTop, .playlists, .artist, .playlist, .album, .artistsTopTracks, .artistsAlbums, .artistsRelatedArtists:
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
        case .artistsTopTracks:
            return [URLQueryItem(name: "market", value: "HR")]
        case .profile, .artist, .playlist, .album, .artistsAlbums, .artistsRelatedArtists, .recommendationGenres:
            return nil
        case .recommendation(let parameters):
            return parameters
//            return [
//                URLQueryItem(name: "market", value: "HR"),
//                URLQueryItem(name: "limit", value: String(request.limit)),
//                URLQueryItem(name: "seed_artists", value: request.seedArtists),
//                URLQueryItem(name: "seed_genres", value: request.seedGenres),
//                URLQueryItem(name: "seed_tracks", value: request.seedTracks),
//                URLQueryItem(name: "min_acousticness", value: String(request.minAcousticness)),
//                URLQueryItem(name: "max_acousticness", value: String(request.maxAcousticness)),
//                URLQueryItem(name: "target_acousticness", value: String(request.targetAcousticness)),
//                URLQueryItem(name: "min_danceability", value: String(request.minDanceability)),
//                URLQueryItem(name: "max_danceability", value: String(request.maxDanceability)),
//                URLQueryItem(name: "target_danceability", value: String(request.targetDanceability)),
//                URLQueryItem(name: "min_duration_ms", value: String(request.minDurationMs)),
//                URLQueryItem(name: "max_duration_ms", value: String(request.maxDurationMs)),
//                URLQueryItem(name: "target_duration_ms", value: String(request.targetDurationMs)),
//                URLQueryItem(name: "min_energy", value: String(request.minEnergy)),
//                URLQueryItem(name: "max_energy", value: String(request.maxEnergy)),
//                URLQueryItem(name: "target_energy", value: String(request.targetEnergy)),
//                URLQueryItem(name: "min_instrumentalness", value: String(request.minInstrumentalness)),
//                URLQueryItem(name: "max_instrumentalness", value: String(request.maxInstrumentalness)),
//                URLQueryItem(name: "target_instrumentalness", value: String(request.targetInstrumentalness)),
//                URLQueryItem(name: "min_key", value: String(request.minKey)),
//                URLQueryItem(name: "max_key", value: String(request.maxKey)),
//                URLQueryItem(name: "target_key", value: String(request.targetKey)),
//                URLQueryItem(name: "min_liveness", value: String(request.minLiveness)),
//                URLQueryItem(name: "max_liveness", value: String(request.maxLiveness)),
//                URLQueryItem(name: "target_liveness", value: String(request.targetLiveness)),
//                URLQueryItem(name: "min_loudness", value: String(request.minLoudness)),
//                URLQueryItem(name: "max_loudness", value: String(request.maxLoudness)),
//                URLQueryItem(name: "target_loudness", value: String(request.targetLoudness)),
//                URLQueryItem(name: "min_mode", value: String(request.minMode)),
//                URLQueryItem(name: "max_mode", value: String(request.maxMode)),
//                URLQueryItem(name: "target_mode", value: String(request.targetMode)),
//                URLQueryItem(name: "min_popularity", value: String(request.minPopularity)),
//                URLQueryItem(name: "max_popularity", value: String(request.maxPopularity)),
//                URLQueryItem(name: "target_popularity", value: String(request.targetPopularity)),
//                URLQueryItem(name: "min_speechiness", value: String(request.minSpeechiness)),
//                URLQueryItem(name: "max_speechiness", value: String(request.maxSpeechiness)),
//                URLQueryItem(name: "target_speechiness", value: String(request.targetSpeechiness)),
//                URLQueryItem(name: "min_tempo", value: String(request.minTempo)),
//                URLQueryItem(name: "max_tempo", value: String(request.maxTempo)),
//                URLQueryItem(name: "target_tempo", value: String(request.targetTempo)),
//                URLQueryItem(name: "min_time_signature", value: String(request.minTimeSignature)),
//                URLQueryItem(name: "max_time_signature", value: String(request.maxTimeSignature)),
//                URLQueryItem(name: "target_time_signature", value: String(request.targetTimeSignature)),
//                URLQueryItem(name: "min_valence", value: String(request.minValence)),
//                URLQueryItem(name: "max_valence", value: String(request.maxValence)),
//                URLQueryItem(name: "target_valence", value: String(request.targetValence))
//            ]
        }
    }
}
