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
    
    // MARK: - Public properties
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init() {
        
    }
}

// MARK: - Public extensions
extension QueueViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
}
