//
//  HomeViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine

struct HomeStats {
    let title: String
    let count: Int
}

final class HomeViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var profile: Profile?

    // MARK: - Coordinator actions
    let homeModuleDidAppear = PassthroughSubject<Void, Never>()
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    let didSelectNotifications = PassthroughSubject<Void, Never>()

    // MARK: - Private properties
    private let homeService: HomeService

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Class lifecycle
    init(homeService: HomeService) {
        self.homeService = homeService
    }
}

// MARK: - Public extension
extension HomeViewModel {
    
    func viewDidAppear() {
        getProfile()
    }
    
    func getProfile() {
        homeService.getProfile()
            .sink { [weak self] profile in
                self?.profile = profile
            }
            .store(in: &cancellables)
    }
    
    func profileButtonTapped() {
        onDidTapProfileButton.send()
    }

    func onNotificationTap() {
        didSelectNotifications.send()
    }
}
