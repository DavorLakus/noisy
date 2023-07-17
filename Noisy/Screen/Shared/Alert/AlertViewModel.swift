//
//  AlertViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 16.07.2023..
//

import Combine
import SwiftUI

final class AlertViewModel: ObservableObject {
    // MARK: - Coordinator actions
    var onDidTapPrimaryAction: PassthroughSubject<Void, Never>?
    var onDidTapSecondaryAction: PassthroughSubject<Void, Never>?
    let onViewDidAppear = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    @Published var title: String?
    @Published var message: String?
    @Published var primaryActionText: String?
    @Published var secondaryActionText: String?
    var primaryBackground: Color?
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published properties
    @Published var isPresented = false

    // MARK: - Class lifecycle
    init(isPresented: Published<Bool>) {
        _isPresented = isPresented
    }
}

// MARK: - Public extension
extension AlertViewModel {
    func viewDidAppear() {
        onViewDidAppear.send()
    }
    
    func primaryActionTapped() {
        isPresented = false
        onDidTapPrimaryAction?.send()
    }

    func secondaryActionTapped() {
        isPresented = false
        onDidTapSecondaryAction?.send()
    }
}
