//
//  SeedParametersSheetView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import SwiftUI

struct SeedParametersSheetView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @State var width: CGFloat = .zero
    @State var isScrollDisabled = false
    let colors: [Color] = [.purple300, .blue400, .orange500, .yellow400, .green200, .green300, .green400, .green500, .green600, .red400, .red500, .red600, .orange400, .purple900 ]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: viewModel.changeSeedParametersButtonTapped) {
                    Text(String.Shared.done)
                        .foregroundColor(.green500)
                        .font(.nunitoBold(size: 18))
                }
            }
            .padding([.horizontal, .top], Constants.margin)
            VStack(alignment: .leading) {
                Text(String.Discover.seedsTitle)
                    .font(.nunitoBold(size: 18))
                    .foregroundColor(.gray800)
            }
            .padding(.horizontal, Constants.margin)
            
            ScrollView {
                VStack {
                    Button(action: viewModel.selectAllSeedsTapped) {
                        HStack {
                            Text(viewModel.notAllSeedParametersSelected ? String.Discover.includeAllSeeds : String.Discover.removeAllSeeds)
                                .font(.nunitoSemiBold(size: 16))
                            
                            (viewModel.notAllSeedParametersSelected ? Image.Shared.checkbox : Image.Shared.checkboxFill)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, Constants.margin)
                    .animation(nil, value: viewModel.notAllSeedParametersSelected)
                    
                    PieGraph(seedToggles: $viewModel.seedToggles, lowerBounds: $viewModel.lowerBounds, targets: $viewModel.targets, upperBounds: $viewModel.upperBounds, width: width - Constants.margin, isScrollDisabled: $isScrollDisabled, colors: colors)
                    
                    LazyVStack {
                        ForEach(Seed.allCases, id: \.id) { seed in
                            ThreePointSliderRow(seed: seed, infoAction: viewModel.seedInfoTapped, minValue: 0, maxValue: 1, lowerBound: $viewModel.lowerBounds[seed.id], target: $viewModel.targets[seed.id], upperBound: $viewModel.upperBounds[seed.id], isToggled: $viewModel.seedToggles[seed.id], background: colors[seed.rawValue])
                                .padding(.horizontal, Constants.margin)
                        }
                    }
                    .readSize { width = $0.width }
                    .padding(.vertical, Constants.margin)
                }
            }.scrollDisabled(isScrollDisabled)
        }
        
        .alert(isPresented: $viewModel.isInfoAlertPresented) { isPresented in
            AlertView(isPresented: isPresented, title: viewModel.infoSeed?.name, message: viewModel.infoSeed?.description, secondaryActionText: .Shared.ok)
        }
    }
}
