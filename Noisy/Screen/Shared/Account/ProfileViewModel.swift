//
//  ProfileViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 16.07.2023..
//

import SwiftUI
import Combine

final class ProfileViewModel: ObservableObject {
    // MARK: - Coordinator actions
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    let onDidTapProfileView = PassthroughSubject<Void, Never>()
    let onDidTapSignOut = PassthroughSubject<Void, Never>()
    
    // MARK: - Published properties
    @Published var viewLoaded = false
    @Published var isPushNavigation = false
    
    // MARK: - Public properties
    var profile: Profile? {
        guard let profile  = UserDefaults.standard.object(forKey: .Login.profile) as? Data
        else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: profile)
    }
}

// MARK: - Public extension
extension ProfileViewModel {
    func viewDidAppear() {
        withAnimation {
            viewLoaded = true
        }
    }
    
    func viewWillDisappear(isPushNavigation: Bool = false) {
        self.isPushNavigation = isPushNavigation
        withAnimation(.easeInOut(duration: 0.25)) {
            viewLoaded = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) { [weak self] in
            self?.closeButtonTapped()
        }
    }
    
    func closeButtonTapped() {
        onDidTapBackButton.send()
    }
    
    func profileViewTapped() {
        onDidTapProfileView.send()
    }
    
    func signOutTapped() {
        onDidTapSignOut.send()
    }
}
