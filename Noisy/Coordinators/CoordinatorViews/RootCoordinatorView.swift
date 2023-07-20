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
        }
        .modalSheet(isPresented: $coordinator.isProfileDrawerPresented, content: coordinator.presentProfileView)
        .alert(isPresented: $coordinator.isAlertPresented, alert: coordinator.presentAlertView)
        .tint(.green500)
        .fullScreenCover(isPresented: $coordinator.isPlayerCoordinatorViewPresented, content: coordinator.presentPlayerCoordinatorView)
    }
}
