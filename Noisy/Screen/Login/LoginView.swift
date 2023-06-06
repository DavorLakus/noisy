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
                .font(.nutinoBold(size: 54))
                .foregroundColor(.green900)
            Text(String.Login.subtitle)
                .font(.nutinoRegular(size: 16))
                .foregroundColor(.gray600)
        }
        .padding(.vertical, Constants.margin)
    }
    
    @ViewBuilder
    var loginInfo: some View {
        VStack(spacing: 48) {
            ZStack(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(String.Login.email)
                        .font(.nutinoSemiBold(size: 14))
                        .foregroundColor(.gray800)
                        .frame(alignment: .leading)
                    TextField(String.Login.textfieldPlaceholder, text: $viewModel.email)
                        .focused($isEditing)
                        .font(.nutinoRegular(size: 14))
                        .foregroundColor(.gray700)
                        .padding(Constants.spacing)
                        .cornerRadius(Constants.smallCornerRadius)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .background {
                            RoundedRectangle(cornerRadius: Constants.smallCornerRadius)
                                .stroke(viewModel.presentError ? Color.red400 : isEditing ? Color.orange400 : Color.gray200)
                        }
                        .padding(.bottom, 24)
                }
                if viewModel.presentError {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red400)
                        .font(.nutinoRegular(size: 12))
                        .zStackTransition(.opacity)
                }
            }
            
            Button {
                viewModel.loginTapped()
            } label: {
                Text(String.Login.loginButtonTitle)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .font(.nutinoSemiBold(size: 18))
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
                .font(.nutinoRegular(size: 14))
        }
    }
}
