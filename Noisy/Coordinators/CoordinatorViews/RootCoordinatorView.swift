//
//  RootCoordinatorView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

struct RootCoordinatorView: View {
    @StateObject var coordinator: RootCoordinator
    @Namespace var namespace

    var body: some View {
        TabView(selection: $coordinator.tab) {
            coordinator.homeTab()
                .tabItem { tab(name: .Tabs.home, icon: .Tabs.home) }
                .tag(RootTab.home)
            coordinator.discoverTab()
                .tabItem { tab(name: .Tabs.discover, icon: .Tabs.discover) }
                .tag(RootTab.discover)
            coordinator.searchTab()
                .tabItem { tab(name: .Tabs.search, icon: .Tabs.search) }
                .tag(RootTab.search)
            coordinator.radio()
                .tabItem { tab(name: .Tabs.radio, icon: .Tabs.radio) }
                .tag(RootTab.radio)
            coordinator.settingsTab()
                .tabItem { tab(name: .Tabs.settings, icon: .Tabs.settings) }
                .tag(RootTab.settings)

        }
        .tint(.orange400)
    }
}

// MARK: Tabs
extension RootCoordinatorView {
    
}
