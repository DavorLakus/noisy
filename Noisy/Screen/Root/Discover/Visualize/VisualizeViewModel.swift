//
//  VisualizeViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 15.08.2023..
//

import SwiftUI
import Combine

final class VisualizeViewModel: ObservableObject {
    // MARK: Published properties
    @Published var isOptionsSheetPresented = false
    @Published var isToastPresented = false
    @Published var recommendedTracks: [Track]
    @Published var tabBarVisibility: Visibility?

    
    // MARK: - Coordinator actions
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumButton = PassthroughSubject<Album, Never>()
    let onDidTapAddToPlaylist = PassthroughSubject<[Track], Never>()
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    var options: [OptionRow] = []
    var toastMessage: String = .empty
    var profile: Profile? {
        guard let profile  = UserDefaults.standard.object(forKey: .Login.profile) as? Data
        else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: profile)
    }
    
    // MARK: - Private properties
    private let discoverService: DiscoverService
    private let musicDetailsService: MusicDetailsService
    private let queueManager: QueueManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(tracks: [Track], discoverService: DiscoverService, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.discoverService = discoverService
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        recommendedTracks = tracks
        fetchTrackMetrics()
    }
}

// MARK: - Public extension
extension VisualizeViewModel {
    func backButtonTapped() {
        withAnimation {
            tabBarVisibility = .visible
        }
        
        Just(onDidTapBackButton)
            .delay(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink {
                $0.send()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private extension
private extension VisualizeViewModel {
    func fetchTrackMetrics() {
        
    }
}
