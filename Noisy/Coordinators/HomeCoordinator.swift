//
//  HomeCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine
import SwiftUI

enum HomePath: Hashable, Identifiable {
    case details

    var id: String {
        String(describing: self)
    }
}

final class HomeCoordinator: VerticalCoordinatorProtocol {
    // MARK: - Published properties
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Public properties
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private var homeViewModel: HomeViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Services
    private let homeService: HomeService
    
    // MARK: - Class lifecycle
    init(homeService: HomeService) {
        self.homeService = homeService
        bindHomeViewModel()
    }
    
    func start() -> some CoordinatorViewProtocol {
        HomeCoordinatorView(coordinator: self)
    }

    @ViewBuilder
    func rootView() -> some View {
        if let homeViewModel {
            HomeView(viewModel: homeViewModel)
                .navigationDestination(for: HomePath.self, destination: navigationDestination)
        }
    }
    
    @ViewBuilder
    func navigationDestination(_ path: HomePath) -> some View {
        switch path {
        case .details:
            Color.red
        }
    }
    
    func push(_ path: HomePath) {
        navigationPath.append(path)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
}

// MARK: - Binding
extension HomeCoordinator {
    func bindHomeViewModel() {
        homeViewModel = HomeViewModel(homeService: homeService)
        
        homeViewModel?.onDidTapProfileButton
            .sink { [weak self] in
                self?.onDidTapProfileButton.send()
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

// MARK: - CoordinatorView
struct HomeCoordinatorView<Coordinator: VerticalCoordinatorProtocol>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
//        .alert(isPresented: $coordinator.alertIsPresented) {
//            coordinator.presentAlert()
//        }
//        .onAppear(perform: coordinator.viewDidAppear)
//        .onDisappear(perform: coordinator.viewDidDisappear)
    }
}
