//
//  RootCoordinatorView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

struct RootCoordinatorView: View {
    @StateObject var coordinator: RootCoordinator
    @State var detents = Set<PresentationDetent>()
    @Namespace var namespace

    var body: some View {
        TabView(selection: $coordinator.tab) {
            coordinator.homeTab()
                .miniPlayerView(coordinator.presentMiniPlayer)
                .tabItem { tab(name: .Tabs.home, icon: .Tabs.home) }
                .tag(RootTab.home)
            coordinator.discoverTab()
                .miniPlayerView(coordinator.presentMiniPlayer)
                .tabItem { tab(name: .Tabs.discover, icon: .Tabs.discover) }
                .tag(RootTab.discover)
            coordinator.searchTab()
                .miniPlayerView(coordinator.presentMiniPlayer)
                .tabItem { tab(name: .Tabs.search, icon: .Tabs.search) }
                .tag(RootTab.search)
        }
        .sheet(isPresented: $coordinator.isProfileDrawerPresented) {
            coordinator.presentProfileView()
                .readSize {
                    detents = [.height($0.height)]
                }
                .presentationDetents(detents)
        }
        .alert(isPresented: $coordinator.isAlertPresented, alert: coordinator.presentAlertView)
        .tint(.purple900)
        .fullScreenCover(isPresented: $coordinator.isPlayerCoordinatorViewPresented, content: coordinator.presentPlayerCoordinatorView)
    }
}

extension View {
    func miniPlayerView<Content: View>(_ miniPlayer: () -> Content) -> some View {
        ZStack(alignment: .bottom) {
            self
            miniPlayer()
        }
    }
}
