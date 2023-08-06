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
    
    // MARK: - Public properties
    var profile: Profile? {
        guard let profile  = UserDefaults.standard.object(forKey: .Login.profile) as? Data
        else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: profile)
    }
}

// MARK: - Public extension
extension ProfileViewModel {
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
