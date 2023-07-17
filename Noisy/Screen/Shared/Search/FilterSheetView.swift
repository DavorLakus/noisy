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
        ZStack(alignment: .topLeading) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                sheetHeader(title: "Filter")

                Rectangle()
                    .fill(Color.gray200)
                    .frame(height: 1)
                    .padding(.bottom, 16)

                if isSort {
                    sortBody()
                } else {
                    filterBody(options: ["option one", "option due"])
                }
            }
        }
    }
}

// MARK: - private extension
private extension FilterSheetView {
    @ViewBuilder
    func sheetHeader(title: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray800)
                .font(.nunitoSemiBold(size: 16))
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

    @ViewBuilder
    func sortBody() -> some View {
        ForEach(EmployeeSort.allCases, id: \.self) { sortingOption in
            SingleSelectionRow(isSelected: .constant(viewModel.sortingOption == sortingOption), title: sortingOption.title) {
                viewModel.sortingOptionSelected(sortingOption)
            }
        }
    }
}
