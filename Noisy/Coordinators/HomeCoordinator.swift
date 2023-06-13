//
//  HomeCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine
import SwiftUI

final class HomeCoordinator: ObservableObject {

    // MARK: - Published properties
    @Published var path = NavigationPath()
    
    // MARK: - Public properties
    
    // MARK: - Private properties
    private lazy var homeViewModel = HomeViewModel(homeService: homeService)
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Services
    private let homeService: HomeService
    
    // MARK: - Class lifecycle
    init(homeService: HomeService) {
        self.homeService = homeService
        bindHomeViewModel()
    }

    // Grafika muzike, statistike, itd.
    func homeView() -> some View {
        HomeView(viewModel: self.homeViewModel)
    }
}

// MARK: - Binding
extension HomeCoordinator {
    func bindHomeViewModel() {
        homeViewModel.homeModuleDidAppear
            .sink {

            }
            .store(in: &cancellables)
    }
}

// MARK: - CoordinatorView lifecycle
extension HomeCoordinator {
    func viewDidAppear() {
//        bindErrorHandling()
    }
    
    func viewDidDisappear() {
//        errorAlertCancellable = nil
    }
}
