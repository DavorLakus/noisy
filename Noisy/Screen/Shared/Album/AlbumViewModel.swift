//
//  AlbumViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import Combine
import SwiftUI

final class AlbumViewModel: ObservableObject, Equatable {
    static func == (lhs: AlbumViewModel, rhs: AlbumViewModel) -> Bool {
        lhs.album != rhs.album
    }
    
    // MARK: - Published properties
    
    // MARK: - Public properties
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    let onDidTapTrackRow = PassthroughSubject<Track, Never>()
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    
    // MARK: - Private properties
    private let album: Album
    private let musicDetailsService: MusicDetailsService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(album: Album, musicDetailsService: MusicDetailsService) {
        self.album = album
        self.musicDetailsService = musicDetailsService
    }
}

// MARK: - Public extension
extension AlbumViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func trackRowTapped(for track: Track) {
        onDidTapTrackRow.send(track)
    }
    
    func artistButtonTapped(for artist: Artist) {
        onDidTapArtistButton.send(artist)
    }
}

// MARK: - Private extension
private extension AlbumViewModel {
    
}
