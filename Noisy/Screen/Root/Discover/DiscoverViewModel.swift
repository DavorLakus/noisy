//
//  DiscoverViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI
import Combine

final class DiscoverViewModel: ObservableObject {
  // MARK: Published properties
    
    // MARK: - Coordinator actions
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    private let discoverService: DiscoverService
    
    // MARK: - Public properties
    var profile: Profile? {
        guard let profile  = UserDefaults.standard.object(forKey: .Login.profile) as? Data
        else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: profile)
    }
    
    // MARK: - Class lifecycle
    init(discoverService: DiscoverService) {
        self.discoverService = discoverService
    }
}

extension DiscoverViewModel {
    func profileButtonTapped() {
        onDidTapProfileButton.send()
    }
}
