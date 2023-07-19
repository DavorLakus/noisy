//
//  PlayerViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

final class PlayerViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var trackPosition: Double = 10
    @Published var trackMaxPosition: Double = 120
    @Published var isPlaying = false
    
    // MARK: - Public properties
    var onDidTapDismissButton: PassthroughSubject<Void, Never>?
    let onDidTapOptionsButton = PassthroughSubject<Void, Never>()
    let onDidTapQueueButton = PassthroughSubject<Void, Never>()
    let onDidTapShareButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private let playerService: PlayerService
    
    // MARK: - Class lifecycle
    init(playerService: PlayerService, queueManager: QueueManager) {
        self.playerService = playerService
    }
    
}

// MARK: - Public extension
extension PlayerViewModel {
    func dismissButtonTapped() {
        onDidTapDismissButton?.send()
    }
    
    func optionsButtonTapped() {
        onDidTapOptionsButton.send()
    }
    
    func addToFavoritesButtonTapped() {
        
    }
    
    func backButtonTapped() {
        onDidTapDismissButton?.send()
    }
    
    func previousButtonTapped() {
        
    }

    func playPauseButtonTapped() {
        isPlaying.toggle()
    }
    
    func nextButtonTapped() {
        
    }
    
    func queueButtonTapped() {
        onDidTapQueueButton.send()
    }
    
    func shareButtonTapped() {
        onDidTapShareButton.send()
    }
}
