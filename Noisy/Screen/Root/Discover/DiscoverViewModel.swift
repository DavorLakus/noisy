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
    
    // MARK: - Public properties
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    private let discoverService: DiscoverService
    
    // MARK: - Class lifecycle
    init(discoverService: DiscoverService) {
        self.discoverService = discoverService
    }
}
