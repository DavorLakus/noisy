//
//  AuthView.swift
//  Noisy
//
//  Created by Davor Lakus on 10.10.2023..
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .trailing) {
                trailingToolbarButton()
            AuthWebView(viewModel: viewModel)
        }
    }
}

// MARK: - Private extension
private extension AuthView {
    @ViewBuilder
    func trailingToolbarButton() -> some View {
        Button(action: viewModel.backButtonTapped) {
            Text(String.close)
                .font(.nunitoSemiBold(size: 16))
                .foregroundColor(.gray600)
        }
        .padding(Constants.margin)
    }
}
