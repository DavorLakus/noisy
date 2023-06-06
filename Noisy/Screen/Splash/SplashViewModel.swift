//
//  SplashViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 02.06.2023..
//

import SwiftUI
import Combine

final class SplashViewModel: ObservableObject {
    
    // MARK: - Coordinator actions
    var onSplashAnimationDidEnd = PassthroughSubject<Void, Never>()
    
    // MARK: - Published properties
    @Published var title: String = "n"
    let titleComponents = ["o", "i", "s", "y"]
}

// MARK: Public extension
extension SplashViewModel {
    func startAnimation() {
        withAnimation(.easeInOut(duration: 1.0)) {
            typeWriter()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.onSplashAnimationDidEnd.send()
        }
    }
}

// MARK: Private extension
extension SplashViewModel {
    func typeWriter(at position: Int = 0) {
        if position < titleComponents.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self ] in
                guard let self else { return }
                self.title.append(self.titleComponents[position])
                self.typeWriter(at: position + 1)
            }
        }
    }
}

