//
//  VisualizeView.swift
//  Noisy
//
//  Created by Davor Lakus on 15.08.2023..
//


import SwiftUI

struct VisualizeView: View {
    @ObservedObject var viewModel: VisualizeViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()
                .randomCirclesOverlay(count: 3)
                .opacity(0.7)
            
//            bodyView()
            headerView()
        }
        .ignoresSafeArea(edges: .all)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .tabBarHidden($viewModel.tabBarVisibility)

    }
}

// MARK: - Header
private extension VisualizeView {
    func headerView() -> some View {
        VStack(alignment: .leading) {
            Button(action: viewModel.backButtonTapped) {
                Image.Shared.chevronLeft
                    .foregroundColor(.gray700)
                    .padding(8)
                    .background {
                        Circle()
                            .fill(Color.mint600)
                            .shadow(radius: 2)
                    }
            }
            HStack {
                Spacer()
                Text(String.Visualize.visualize)
                    .font(.nunitoBold(size: 24))
                    .foregroundColor(.gray800)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 36)
                            .fill(Color.appBackground)
                            .shadow(radius: 2)
                    }
            }
        }
        .padding(.top, Constants.mediumIconSize)
        .padding(Constants.margin)
    }
}
