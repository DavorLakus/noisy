//
//  LoginCoordinatorView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

struct LoginCoordinatorView: View {
    @ObservedObject var coordinator: LoginCoordinator
    
    var body: some View {
        coordinator.loginView()
        .sheet(isPresented: $coordinator.authSheetIsPresented, content: coordinator.authSheet)
        .onAppear(perform: coordinator.viewDidAppear)
        .onDisappear(perform: coordinator.viewDidDisappear)
    }
}
