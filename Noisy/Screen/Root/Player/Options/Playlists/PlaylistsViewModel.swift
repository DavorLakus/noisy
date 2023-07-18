//
//  PlaylistsViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

final class PlaylistsViewModel: ObservableObject {
    // MARK: - Published properties
    
    // MARK: - Public properties
    let onDidTapCancelButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private let playerService: PlayerService
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(playerService: PlayerService) {
        self.playerService = playerService
    }
}

// MARK: - Public extensions
extension PlaylistsViewModel {
    
}
