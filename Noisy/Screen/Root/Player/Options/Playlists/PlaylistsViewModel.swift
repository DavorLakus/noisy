//
//  PlaylistsViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import Combine
import SwiftUI

final class PlaylistsViewModel: ObservableObject {
    // MARK: - Published properties
    
    // MARK: - Public properties
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    let onDidTapPlaylistRow = PassthroughSubject<[Track], Never>()
    
    // MARK: - Private properties
    private let playlists: [Album]
    private let musicDetailsService: MusicDetailsService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(playlists: [Album], musicDetailsService: MusicDetailsService) {
        self.playlists = playlists
        self.musicDetailsService = musicDetailsService
    }
}

// MARK: - Public extension
extension PlaylistsViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func playlistRowTapped() {
        
    }
}

// MARK: - Private extension
private extension PlaylistsViewModel {
    
}
