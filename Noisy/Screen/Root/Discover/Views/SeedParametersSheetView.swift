//
//  SeedParametersSheetView.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import SwiftUI

struct SeedParametersSheetView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    
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
            ScrollView {
                VStack(alignment: .leading) {
                    Text(String.Discover.seedsTitle)
                        .font(.nunitoBold(size: 18))
                        .foregroundColor(.gray800)
                }
                .padding(.horizontal, Constants.margin)
                
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
                    LazyVStack {
                        ForEach(Seed.allCases, id: \.id) { seed in
                            ThreePointSliderRow(seed: seed, infoAction: {}, minValue: 0, maxValue: 1, lowerBound: $viewModel.lowerBounds[seed.id], target: $viewModel.targets[seed.id], upperBound: $viewModel.upperBounds[seed.id], isToggled: $viewModel.seedToggles[seed.id])
                                .padding(.horizontal, Constants.margin)
                        }
                    }
                }
                .padding(.vertical, Constants.margin)
            }
        }
    }
}
