//
//  SearchResult.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import Foundation

struct SearchResult: Codable {
    let tracks: Tracks?
    let artists: ArtistsResponse?
    let albums: AlbumResponse?
    let playlists: PlaylistsResponse?
}
