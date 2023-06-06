//
//  HomeView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @Environment(\.colorScheme) var appearance
    @AppStorage("selectedAppearance") var selectedAppearance: Appearance = .light
    @State var hasNewNotifications: Bool = true
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: Constants.margin, alignment: nil),
        GridItem(.flexible(), spacing: Constants.margin, alignment: nil)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.cmxWhite.ignoresSafeArea()
            Color.appBackground
            navigationBarBottomBorder()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: Constants.margin) {
                    ForEach(Array(zip(viewModel.stats.indices, viewModel.stats)), id: \.0) { index, item in
                        createCard(for: item, index: index)
                    }
                }
                .padding(Constants.margin)
            }
        }
        .toolbar {
            leadingLargeTitle(title: String.Tabs.home)
            trailingNavigationBarItem()
        }
        .onAppear {
            selectedAppearance = appearance == .light ? .light : .dark
        }
    }
}

// MARK: - Toolbar
