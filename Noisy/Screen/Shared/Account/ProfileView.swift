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
        ZStack {
            if viewModel.viewLoaded {
                Color.alertShadow
                    .ignoresSafeArea()
                    .opacity(0.7)
                    .zStackTransition(viewModel.isPushNavigation ? .move(edge: .leading) : .opacity)
                    .onTapGesture { viewModel.viewWillDisappear() }
                
                bodyView()
                    .padding(.leading, 80)
                    .zStackTransition(viewModel.isPushNavigation ? .move(edge: .leading) : .move(edge: .trailing))
            }
        }
        .onAppear(perform: viewModel.viewDidAppear)
    }
}

// MARK: - Body
extension ProfileView {
    @ViewBuilder
    func bodyView() -> some View {
        ZStack(alignment: .topTrailing) {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: .zero) {
                closeButton()
                
                VStack(spacing: 36) {
                    profileView()
                    
                    generalView()
                    
                    Spacer()
                }
                .padding(Constants.margin)
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    func closeButton() -> some View {
        HStack {
            Spacer()
            Button {
                viewModel.viewWillDisappear()
            } label: {
                Image.Shared.close
                    .tint(.gray700)
            }
        }
        .padding(Constants.margin)
        
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
                        .font(.nunitoSemiBold(size: 14))
                        .foregroundColor(.gray900)
                    Text(String.Account.viewProfile)
                        .font(.nunitoSemiBold(size: 12))
                        .underline()
                        .foregroundColor(.gray600)
                }
                Spacer()
                Image.Shared.chevronRight
                    .foregroundColor(.purple600)
            }
        }
        .padding(.vertical)
        .bottomBorder()
        .background { Color.appBackground }
        .onTapGesture {
            viewModel.profileViewTapped()
        }
    }
    
    @ViewBuilder
    func generalView() -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(String.Account.general)
                .font(.nunitoSemiBold(size: 14))
                .foregroundColor(.gray700)
            Group {
                Text(String.Account.about)
                    .font(.nunitoRegular(size: 16))
                    .foregroundColor(.gray500)
                
                Button {
                    viewModel.signOutTapped()
                } label: {
                    Text(String.Profile.signOutTitle)
                        .font(.nunitoRegular(size: 16))
                        .foregroundColor(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { Color.appBackground }
            .padding(.vertical, 16)
            .bottomBorder()
        }
    }
}
