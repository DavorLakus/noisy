//
//  RootCoordinatorView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

private struct AlertKey: EnvironmentKey {
    // 1
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isAlertPresented: Bool {
        get { self[AlertKey.self] }
        set { self[AlertKey.self] = newValue }
    }
}

struct RootCoordinatorView: View {
    @StateObject var coordinator: RootCoordinator
    @Namespace var namespace
    @State var isAlertPresented = false
    
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
        .dynamicModalSheet(isPresented: $coordinator.isProfileDrawerPresented, content:  coordinator.presentProfileView)
        .alert(isPresented: $coordinator.isAlertPresented, alert: coordinator.presentAlertView)
        .tint(.purple900)
    }
}

extension View {
    func miniPlayerView<Content: View>(isPresented: Binding<Bool>, miniPlayer: () -> Content) -> some View {
        ZStack(alignment: .bottom) {
            self
            if isPresented.wrappedValue {
                miniPlayer()
                    .zStackTransition(.move(edge: .bottom))
            }
        }
    }
}
