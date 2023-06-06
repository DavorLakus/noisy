//
//  ViewModifiers.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

struct TabBarHidden: ViewModifier {
    @Binding var visibility: Visibility?
    
    func body(content: Content) -> some View {
            content
            .onAppear {
                withAnimation {
                    visibility = .hidden
                }
            }
            .toolbar(visibility ?? .hidden, for: .tabBar)
        }
}

struct ZStackTransition: ViewModifier {
    let transition: AnyTransition
    
    func body(content: Content) -> some View {
        content
            .zIndex(1)
            .transition(transition)
    }
}
