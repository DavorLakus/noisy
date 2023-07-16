//
//  HomeView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI
import WebKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.colorScheme) var appearance
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: Constants.margin, alignment: nil),
        GridItem(.flexible(), spacing: Constants.margin, alignment: nil)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()
            Color.appBackground
            navigationBarBottomBorder()
            
            ScrollView {
                Text("Welcome " + (viewModel.profile?.displayName ?? .empty))
//                LazyVGrid(columns: columns, spacing: Constants.margin) {
//                    ForEach(Array(zip(viewModel.stats.indices, viewModel.stats)), id: \.0) { index, item in
//                        createCard(for: item, index: index)
//                    }
//                }
//                .padding(Constants.margin)
            }
        }
        .onAppear(perform: viewModel.viewDidAppear)
        .toolbar {
            leadingLargeTitle(title: String.Tabs.home)
            trailingNavigationBarItem()
        }
    }
}

// MARK: - ToolbarContentBuilder
private extension HomeView {
    @ToolbarContentBuilder
    func trailingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button {
                    viewModel.onNotificationTap()
                } label: {
                    Image.Home.sparkles
                        .foregroundColor(.gray700)
                }
                
                Button {
                    viewModel.profileButtonTapped()
                } label: {
                    AsyncImage(url: URL(string: viewModel.profile?.images.first?.url ?? .empty)) { image in
                        image.resizable()
                    } placeholder: {
                        Image.Home.profile.resizable()
                    }
                    .scaledToFit()
                    .cornerRadius(18)
                    .frame(width: 36, height: 36)
                }
            }
            .padding(8)
        }
    }
}

// MARK: - Body components
private extension HomeView {
    func createCard(for item: HomeStats, index: Int) -> some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {
            Text("\(item.count)")
                .foregroundColor(cardForegroundColor(for: index))
                .font(.nutinoSemiBold(size: 20))
                .frame(width: 56, height: 56)
                .background(cardBackgroundColor(for: index))
                .cornerRadius(28)
            
            Text(item.title)
                .foregroundColor(.gray700)
                .font(.nutinoSemiBold(size: 12))
                .padding(.top, 14)
            
            Spacer()
            
        }
        .frame(height: 136)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(Constants.spacing)
        .cardBackground()
    }
    
    func cardForegroundColor(for index: Int) -> Color {
        switch index % 4 {
        case 0: return Color.green400
        case 1: return Color.purple600
        case 2: return Color.blue400
        default: return Color.cream50
        }
    }
    
    func cardBackgroundColor(for index: Int) -> Color {
        switch index % 4 {
        case 0: return Color.green200
        case 1: return Color.purple100
        case 2: return Color.blue50
        default: return Color.orange400
        }
    }
}
