//
//  Theme.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import UIKit
import SwiftUI

final class Theme {
    func setupTheme() {
        setupTabBarAppearance()
        setupNavigationBarAppearance()
    }
}

// MARK: - Private extensions
private extension Theme {
    func setupTabBarAppearance() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = UIColor(Color.appBackground)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.gray400)
        
        let appearance = UITabBarAppearance()
        appearance.shadowColor = UIColor(Color.gray300)
        appearance.shadowImage = UIImage(named: "tab-shadow")?.withRenderingMode(.alwaysTemplate)
        appearance.backgroundColor = UIColor(Color.appBackground)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color.clear)
        appearance.shadowColor = UIColor(Color.clear)
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
    }
}
