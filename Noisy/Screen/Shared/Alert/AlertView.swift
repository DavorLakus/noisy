//
//  AlertView.swift
//  Noisy
//
//  Created by Davor Lakus on 16.07.2023..
//

import SwiftUI
import Combine

struct AlertView: View {
    @Binding var isPresented: Bool
    @State var title: String?
    @State var message: String?
    @State var primaryActionText: String?
    @State var secondaryActionText: String?
    let primaryAction: (() -> Void)?
    var primaryBackground: Color?
    
    init(isPresented: Binding<Bool>, title: String? = nil, message: String? = nil, primaryActionText: String? = nil, secondaryActionText: String? = nil, primaryAction: (() -> Void)? = nil, primaryBackground: Color? = nil) {
        _isPresented = isPresented
        self.title = title
        self.message = message
        self.primaryActionText = primaryActionText
        self.secondaryActionText = secondaryActionText
        self.primaryAction = primaryAction
        self.primaryBackground = primaryBackground
    }
    
    var body: some View {
        ZStack {
            alertBody()
        }
    }
}

// MARK: - Private extension
private extension AlertView {
    @ViewBuilder
    func alertBody() -> some View {
        VStack(spacing: Constants.spacing) {
            if let title {
                Text(title)
                    .foregroundColor(.gray800)
                    .font(.nunitoSemiBold(size: 16))
                    .animation(.none)
            }
            if let message {
                Text(message)
                    .foregroundColor(.gray600)
                    .multilineTextAlignment(.center)
                    .font(.nunitoRegular(size: 14))
                    .padding(.bottom, 8)
            }
            
            alertActions()
        }
        .padding(Constants.margin)
        .background(Color.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
        .shadow(color: .black.opacity(0.1), radius: 15, y: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.slide)
        .zIndex(1)
        .padding(primaryActionText != nil ? 0 : 40)
    }
    
    @ViewBuilder
    func alertActions() -> some View {
        HStack(spacing: Constants.margin) {
            Button {
                withAnimation {
                    isPresented = false
                }
            } label: {
                Text(secondaryActionText ?? String.cancel)
                    .tint(.gray900)
                    .font(.nunitoRegular(size: 16))
                    .frame(maxWidth: primaryActionText == nil ? .infinity : nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray100)
            .cornerRadius(Constants.smallCornerRadius)
            
            if primaryActionText != nil {
                Button {
                    if let primaryAction {
                        primaryAction()
                    }
                } label: {
                    Text(primaryActionText ?? String.Profile.signoutTitle)
                        .font(.nunitoSemiBold(size: 16))
                        .tint(.appBackground)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(primaryBackground ?? .purple600)
                .cornerRadius(Constants.smallCornerRadius)
            }
        }
    }
}
