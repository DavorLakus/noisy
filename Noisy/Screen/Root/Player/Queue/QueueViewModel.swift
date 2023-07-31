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

    // MARK: - Coordinator actions
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    let queueManager: QueueManager
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(queueManager: QueueManager) {
        self.queueManager = queueManager
    }
}

// MARK: - Public extensions
extension QueueViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func moveTrack(from source: IndexSet, to destination: Int) {
        queueManager.state.tracks.move(fromOffsets: source, toOffset: destination)
    }
}
