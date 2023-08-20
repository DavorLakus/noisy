//
//  ProfileView.swift
//  Noisy
//
//  Created by Davor Lakus on 16.07.2023..
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State var width: CGFloat = .zero
    
    var body: some View {
        bodyView()
    }
}

// MARK: - Body
extension ProfileView {
    @ViewBuilder
    func bodyView() -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: .zero) {
                closeButton()
                profileView()
                generalView()
            }
            .padding(Constants.margin)
            .background {
                Color.appBackground.ignoresSafeArea()
                    .randomCirclesOverlay(with: [.yellow300.opacity(0.9)])
            }
        }
    }
    
    @ViewBuilder
    func closeButton() -> some View {
        HStack {
            Spacer()
            Button {
                viewModel.closeButtonTapped()
            } label: {
                Image.Shared.close
                    .tint(.gray700)
            }
        }
        .padding([.trailing, .top], Constants.margin)
        
    }
    
    @ViewBuilder
    func profileView() -> some View {
        HStack(spacing: 16) {
            if let profile = viewModel.profile {
                LoadImage(url: URL(string: profile.images.first?.url ?? .empty))
                    .scaledToFit()
                    .cornerRadius(18)
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.displayName)
                        .font(.nunitoSemiBold(size: 26))
                        .foregroundColor(.gray900)
                }
                Spacer()
            }
        }
        .padding(.vertical)
        .bottomBorder()
    }
    
    @ViewBuilder
    func generalView() -> some View {
        Button(action: viewModel.signOutTapped) {
            Text(String.Profile.signoutTitle)
                .font(.nunitoSemiBold(size: 18))
                .foregroundColor(.gray600)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .bottomBorder()
    }
}
