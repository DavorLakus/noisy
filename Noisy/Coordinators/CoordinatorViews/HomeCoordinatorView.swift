//
//  HomeCoordinatorView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

enum HomePath: Hashable, Identifiable {
    case details

    var id: String {
        String(describing: self)
    }
}

struct HomeCoordinatorView: View {
    @ObservedObject var coordinator: HomeCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.homeView()
                .navigationDestination(for: HomePath.self, destination: homeDestination)
        }
//        .alert(isPresented: $coordinator.alertIsPresented) {
//            coordinator.presentAlert()
//        }
        .onAppear(perform: coordinator.viewDidAppear)
        .onDisappear(perform: coordinator.viewDidDisappear)
    }
    
    @ViewBuilder
    private func homeDestination(for path: HomePath) -> some View {
        switch path {
        case .details:
            Color.red
        }
    }
}
