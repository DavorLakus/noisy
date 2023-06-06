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
    @Published var stats: [HomeStats] = []

    // MARK: - Coordinator actions
    var onDidTapProfileButton = PassthroughSubject<Void, Never>()
    var didSelectNotifications = PassthroughSubject<Void, Never>()

    // MARK: - Private properties
    private let homeService: HomeService

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Class lifecycle
    init(homeService: HomeService) {
        self.homeService = homeService

        getStats()
    }
}

// MARK: - Public extension
extension HomeViewModel {
    func getStats() {
        homeService.getAnalytics()
            .sink { [weak self] analytics in
                let stats1 = HomeStats(title: String.Home.techComp, count: analytics.distinctCompetencies.technical)
                let stats2 = HomeStats(title: String.Home.nonTechComp, count: analytics.distinctCompetencies.nonTechnical)
                let stats3 = HomeStats(title: String.Home.lang, count: analytics.distinctCompetencies.languages)
                let stats4 = HomeStats(title: String.Home.engineers, count: analytics.employeesByDepartment.softwareEngineers)
                let stats5 = HomeStats(title: String.Home.designers, count: analytics.employeesByDepartment.designers)
                let stats6 = HomeStats(title: String.Home.delManagers, count: analytics.employeesByDepartment.deliveryManagers)
                let stats7 = HomeStats(title: String.Home.businessDevs, count: analytics.employeesByDepartment.businessDevelopers)
                let stats8 = HomeStats(title: String.Home.marketing, count: analytics.employeesByDepartment.marketingExperts)
                let stats9 = HomeStats(title: String.Home.people, count: analytics.employeesByDepartment.peopleAndCultureSpecialists)
                let stats10 = HomeStats(title: String.Home.businessSupport, count: analytics.employeesByDepartment.businessSupport)
                let stats11 = HomeStats(title: String.Home.finance, count: analytics.employeesByDepartment.financeManagers)

                self?.stats.append(contentsOf: [stats1, stats2, stats3, stats4, stats5, stats6, stats7, stats8, stats9, stats10, stats11])
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
