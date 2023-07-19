//
//  AlertView.swift
//  Noisy
//
//  Created by Davor Lakus on 16.07.2023..
//

import SwiftUI
import Combine

struct AlertView: View {
    @ObservedObject var viewModel: AlertViewModel
    
    var body: some View {
        ZStack {
            alertBackground()
            alertBody()
        }
    }
}

// MARK: - Private extension
private extension AlertView {
    @ViewBuilder
    func alertBackground() -> some View {
        if viewModel.isPresented {
            Color.alertShadow
                .opacity(0.7)
                .transition(.opacity)
                .ignoresSafeArea()
                .zIndex(1)
                .onTapGesture {
                    withAnimation {
                        viewModel.secondaryActionTapped()
                    }
                }
        }
    }
    
    @ViewBuilder
    func alertBody() -> some View {
        if viewModel.isPresented {
            VStack(spacing: Constants.spacing) {
                if let title = viewModel.title {
                    Text(title)
                        .foregroundColor(.gray800)
                        .font(.nunitoSemiBold(size: 16))
                        .animation(.none)
                }
                if let message = viewModel.message {
                    Text(message)
                        .foregroundColor(.gray600)
                        .multilineTextAlignment(.center)
                        .font(.nunitoRegular(size: 14))
                        .padding(.bottom, 8)
                }
                
                alertActions()
            }
            .onAppear(perform: viewModel.viewDidAppear)
            .padding(Constants.margin)
            .background(Color.cardBackground)
            .cornerRadius(Constants.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 15, y: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.slide)
            .zIndex(1)
            .padding(viewModel.primaryActionText != nil ? 0 : 40)
        }
    }
    
    @ViewBuilder
    func alertActions() -> some View {
        HStack(spacing: Constants.margin) {
            Button {
                withAnimation {
                    viewModel.secondaryActionTapped()
                }
            } label: {
                Text(viewModel.secondaryActionText ?? String.cancel)
                    .tint(.gray900)
                    .font(.nunitoRegular(size: 16))
                    .frame(maxWidth: viewModel.primaryActionText == nil ? .infinity : nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray100)
            .cornerRadius(Constants.smallCornerRadius)
            
            if viewModel.primaryActionText != nil {
                Button {
                    withAnimation {
                        viewModel.primaryActionTapped()
                    }
                } label: {
                    Text(viewModel.primaryActionText ?? String.Profile.signoutTitle)
                        .font(.nunitoSemiBold(size: 16))
                        .tint(.appBackground)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(viewModel.primaryBackground ?? Color.mint)
                .cornerRadius(Constants.smallCornerRadius)
            }
        }
    }
}
