//
//  SplashView.swift
//  Noisy
//
//  Created by Davor Lakus on 02.06.2023..
//

import SwiftUI

struct SplashView: View {
    @StateObject var viewModel: SplashViewModel

    var body: some View {
        ZStack(alignment: .center) {
            Color.green400.ignoresSafeArea()

            VStack(alignment: .center, spacing: Constants.margin) {
                Text(viewModel.title)
                    .font(.nunitoBold(size: 36))
                    .foregroundColor(.yellow100)
                    .frame(width: 264, alignment: .leading)
            }
        }
        .onAppear {
            viewModel.startAnimation()
        }
    }
}
