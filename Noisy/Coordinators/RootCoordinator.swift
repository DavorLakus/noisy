//
//  RootCoordinator.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI
import Combine

enum RootTab {
    case home
    case discover
    case search
    case liveMusic
    case radio
    case settings
}

final class RootCoordinator: ObservableObject {

    // MARK: - Published properties
    @Published var tab = RootTab.home

    // MARK: - Public properties
    var onDidEnd = PassthroughSubject<Void, Never>()

    // MARK: - Private properties

    // MARK: - Class lifecycle
    init() {
    }

    // Grafika muzike, statistike, itd.
    func homeTab() -> some View {
        Color.yellow
    }
    
    func discoverTab() -> some View {
        Color.green400
    }
    
    func searchTab() -> some View {
        Color.green500
    }
    
    func liveMusicTab() -> some View {
        Color.purple600
    }
    
    func radio() -> some View {
        Color.purple600
    }
    
    func settingsTab() -> some View {
        Color.orange400
    }
}
