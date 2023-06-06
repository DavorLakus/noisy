//
//  MainCoordinatorView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

struct MainCoordinatorView: View {
    @ObservedObject var coordinator: MainCoordinator
    
    var body: some View {
        ZStack {
            switch coordinator.flow {
            case .splash:
                coordinator.showSplashView()
            case .login(let transitionFromSplash):
                coordinator.presentLoginFlow()
                    .transition(.asymmetric(insertion: .move(edge: transitionFromSplash ? .bottom : .leading), removal: .move(edge: .leading)))
            case .home(let transitionFromSplash):
                coordinator.presentRootFlow()
                    .transition(.asymmetric(insertion: .move(edge: transitionFromSplash ? .bottom : .trailing), removal: .move(edge: .trailing)))
            }
        }
        .loadingIndicator(isPresented: $coordinator.isLoading)
        .animation(.easeInOut, value: coordinator.flow)
    }
}
