//
//  LoginView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @FocusState private var isEditing: Bool
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
                .opacity(0.9)
            
            bodyView
        }
    }
}

// MARK: - Private extensions
private extension LoginView {
    var bodyView: some View {
            VStack(spacing: 0) {
                Spacer()
                title
                loginInfo
                Spacer()
                footer
            }
            .padding(.horizontal, Constants.margin)
    }
    
    @ViewBuilder
    var title: some View {
        VStack(spacing: Constants.largeSpacing) {
            Text(String.Login.title)
                .font(.nunitoBold(size: 54))
                .foregroundColor(.green900)
            Text(String.Login.subtitle)
                .font(.nunitoRegular(size: 16))
                .foregroundColor(.gray600)
        }
        .padding(.vertical, Constants.margin)
    }
    
    @ViewBuilder
    var loginInfo: some View {
        VStack(spacing: 48) {
            Button {
                viewModel.loginTapped()
            } label: {
                Text(String.Login.loginButtonTitle)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .font(.nunitoSemiBold(size: 18))
                    .foregroundColor(.appBackground)
                    .background(
                        Color.green400
                        .cornerRadius(Constants.smallCornerRadius)
                    )
            }
        }
        .padding(.horizontal, Constants.margin)
        .padding(.vertical, 28)
        .cardBackground()
    }
    
    @ViewBuilder
    var footer: some View {
        VStack(spacing: 0) {
            Text(String.Login.footer)
                .foregroundColor(.gray600)
                .font(.nunitoRegular(size: 14))
        }
    }
}
