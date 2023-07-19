//
//  NoisyApp.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

@main
struct NoisyApp: App {
    @StateObject var coordinator = MainCoordinator()
    
    init() {
        setupTheme()
    }
    
    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
    
    func setupTheme() {
        let theme = Theme()
        theme.setupTheme()
    }
}
