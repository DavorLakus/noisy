//
//  QueueViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

final class QueueViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var currentTime: Double = 0
    
    // MARK: - Coordinator actions
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    let queueManager: QueueManager
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(queueManager: QueueManager) {
        self.queueManager = queueManager
        
       bindCurrentTime()
    }
}

// MARK: - Public extensions
extension QueueViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func moveTrack(from source: IndexSet, to destination: Int) {
        queueManager.state.tracks.move(fromOffsets: source, toOffset: destination)
        if destination == 0 {
            queueManager.state.currentTrack = queueManager.state.tracks.first
            queueManager.play()
        }
    }
    
    func trackRowSwiped(_ track: EnumeratedSequence<[Track]>.Element) {
        withAnimation {
            queueManager.remove(track)
        }
    }
}

// MARK: - Private extensions
private extension QueueViewModel {
    func bindCurrentTime() {
        queueManager.observedPosition
            .sink { [weak self] position in
                withAnimation(.linear(duration: 0.5)) {
                    self?.currentTime = position
                }
            }
            .store(in: &cancellables)
        currentTime = queueManager.state.currentTime
    }
}
