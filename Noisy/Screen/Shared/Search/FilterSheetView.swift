//
//  FilterSheetView.swift
//  Noisy
//
//  Created by Davor Lakus on 17.07.2023..
//

import SwiftUI

struct FilterSheetView: View {
    @ObservedObject var viewModel: SearchViewModel

    @Binding var isSheetPresented: Bool

    var isSort: Bool

    var body: some View {
        bodyView()
    }
}

// MARK: - private extension
private extension FilterSheetView {
    func bodyView() -> some View {
        ZStack(alignment: .topLeading) {
            Color.green200.ignoresSafeArea()

            VStack(spacing: 0) {
                sheetHeader(title: .Search.searchOptions)

                Rectangle()
                    .fill(Color.gray500)
                    .frame(height: 1)
                    .padding(.bottom, 16)
                
                VStack(alignment: .leading) {
                    Text("\(String.Home.sliderCount) \(Int(viewModel.searchLimit))")
                        .font(.nunitoBold(size: 14))
                    HStack(spacing: Constants.smallSpacing) {
                        Text("1")
                            .font(.nunitoRegular(size: 12))
                            .foregroundColor(.gray800)
                        Slider(value: $viewModel.searchLimit, in: 1...30)
                        Text("30")
                            .font(.nunitoRegular(size: 12))
                            .foregroundColor(.gray800)
                    }
                }
                .padding(.horizontal, Constants.margin)

                filterBody(options: SearchFilterOption.allCases.map(\.id))
            }
        }
    }
    
    @ViewBuilder
    func sheetHeader(title: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray800)
                .font(.nunitoBold(size: 18))
                .frame(maxWidth: .infinity)

            Button(action: {
                isSheetPresented.toggle()
            }, label: {
                Image.Shared.close
                    .foregroundColor(.gray800)
            })
        }
        .padding(Constants.margin)
    }

    @ViewBuilder
    func filterBody(options: [String]) -> some View {
        ForEach(options, id: \.self) { option in
            MultipleSelectionRow(isSelected: .constant(viewModel.filteringOptions.contains(option)), title: option) {
                viewModel.filteringOptionSelected(option)
            }
        }
    }

}
