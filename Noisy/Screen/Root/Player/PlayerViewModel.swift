//
//  PlayerViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine
import AVKit

enum PlayerSliderState {
    case reset
    case slideStarted
    case slideEnded(Double)
}

final class PlayerViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var isPlaying = false
    @Published var timeControlStatus: AVPlayer.TimeControlStatus = .paused
    @Published var trackPosition: TimeInterval = .zero
    @Published var observedPosition: TimeInterval = .zero
    @Published var trackMaxPosition: TimeInterval = 29
    @Published var sliderState: PlayerSliderState = .reset

    // MARK: - Coordinator actions
    var onDidTapDismissButton: PassthroughSubject<Void, Never>?
    let onDidTapOptionsButton = PassthroughSubject<Void, Never>()
    let onDidTapQueueButton = PassthroughSubject<Void, Never>()
    let onDidTapShareButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    var queueManager: QueueManager
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Class lifecycle
    init(queueManager: QueueManager) {
        self.queueManager = queueManager
        bindQueueManager()
    }
    
    func bindQueueManager() {
        queueManager.isPlaying.assign(to: &_isPlaying.projectedValue)
        queueManager.trackPosition
            .sink { [weak self] position in
                withAnimation(.linear(duration: 0.5)) {
                    self?.trackPosition = position
                }
            }
            .store(in: &cancellables)
        queueManager.observedPosition.assign(to: &_observedPosition.projectedValue)
        queueManager.trackMaxPosition.assign(to: &_trackMaxPosition.projectedValue)
        queueManager.timeControlStatus.assign(to: &_timeControlStatus.projectedValue)
        $sliderState.sink { [weak self] state in
            self?.queueManager.sliderState.send(state)
        }
        .store(in: &cancellables)
        
    }
}

// MARK: - Public extension
extension PlayerViewModel {
    
    func backButtonTapped() {
        onDidTapDismissButton?.send()
    }
    
    func optionsButtonTapped() {
        onDidTapOptionsButton.send()
    }
    
    func addToFavoritesButtonTapped() {
        
    }
    
    func previousButtonTapped() {
        queueManager.onDidTapPreviousButton()
    }

    func playPauseButtonTapped() {
        queueManager.onPlayPauseTapped()
    }
    
    func nextButtonTapped() {
        queueManager.onDidTapNextButton()
    }
    
    func queueButtonTapped() {
        onDidTapQueueButton.send()
    }
    
    func shareButtonTapped() {
        onDidTapShareButton.send()
    }
}
