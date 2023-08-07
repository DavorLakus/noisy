//
//  SpotifyErrorAlert.swift
//  Noisy
//
//  Created by Davor Lakus on 07.08.2023..
//

import SwiftUI

struct SpotifyErrorView: View {
    let error: SpotifyError?
    @Binding var isPresented: Bool
    
    var body: some View {
        if let error {
            ZStack {
                Color.gray700
                    .opacity(0.1)
                    .blur(radius: 20)
                    .ignoresSafeArea()
                
                VStack {
                    Text(String.Shared.errorTitle)
                        .font(.nunitoBold(size: 20))
                        .foregroundColor(.gray800)
                    
                    HStack {
                        Text("(\(error.status))")
                            .font(.nunitoSemiBold(size: 14))
                            .foregroundColor(.gray600)
                        Spacer()
                    }
                    Text(error.message)
                        .font(.nunitoSemiBold(size: 18))
                        .foregroundColor(.gray700)
                    Button {
                        withAnimation {
                            isPresented = false
                        }
                    } label: {
                        Text(String.Shared.ok)
                            .font(.nunitoBold(size: 18))
                            .foregroundColor(.purple900)
                    }
                }
                .padding(Constants.margin)
                .background {
                    Color.appBackground.ignoresSafeArea()
                        .randomCirclesOverlay(count: 1, maxFrameMultiplier: 0.8)
                }
                .cardBackground(hasShadow: false)
                .frame(maxWidth: 250)
            }
        }
    }
}
