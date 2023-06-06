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
    
    var body: some Scene {
        WindowGroup {
            MainCoordinatorView(coordinator: coordinator)
        }
    }
}
