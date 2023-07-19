//
//  OptionsViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

final class OptionsViewModel: ObservableObject {
    // MARK: - Published properties
    
    // MARK: - Public properties
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    let onDidTapPlaylistsButton = PassthroughSubject<[Playlist], Never>()
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init() {
        
    }
}

// MARK: - Public extensions
extension OptionsViewModel {
    func backButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func addToPlaylistButtonTapped() {
        onDidTapPlaylistsButton.send([])
    }
}
