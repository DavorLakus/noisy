//
//  AccordionView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct SimpleAccordionView<AccordionData: Hashable, Content: View>: View {
    @Binding var isExpanded: Bool
    let title: String
    var data: EnumeratedSequence<[AccordionData]>
    var dataRowView: (EnumeratedSequence<[AccordionData]>.Iterator.Element, ((AccordionData) -> Void)?) -> Content
    let action: (AccordionData) -> Void
    let optionsAction: ((AccordionData) -> Void)?
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .foregroundColor(.gray700)
                        .font(.nunitoBold(size: 20))
                    
                    Spacer()
                    
                    Image.Shared.chevronRight
                        .rotationEffect(isExpanded ? .degrees(90) : .degrees(0))
                }
                .background { Color.white }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                ForEach(Array(data), id: \.offset) { dataElement in
                    dataRowView(dataElement, optionsAction)
                        .onTapGesture {
                            action(dataElement.element)
                        }
                }
            }
        }
        .padding(Constants.margin)
        .cardBackground()
        .padding(.horizontal, Constants.margin)
    }
}

struct ParameterizedAccordionView<AccordionData: Hashable, Content: View>: View {
    @Binding var isExpanded: Bool
    @Binding var count: Double
    var timeRange: Binding<TimeRange>? 
    let title: String
    let data: EnumeratedSequence<[AccordionData]>
    let dataRowView: (EnumeratedSequence<[AccordionData]>.Iterator.Element, ((AccordionData) -> Void)?) -> Content
    let action: (AccordionData) -> Void
    let optionsAction: ((AccordionData) -> Void)?

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .foregroundColor(.gray700)
                        .font(.nunitoBold(size: 20))
                    
                    Spacer()
                    
                    Image.Shared.chevronRight
                        .rotationEffect(isExpanded ? .degrees(90) : .degrees(0))
                }
                .background { Color.white }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                if let timeRange {
                    HStack {
                        Text(String.Home.pickerTitle)
                            .font(.nunitoRegular(size: 14))
                        Picker(String.Home.pickerTitle, selection: timeRange) {
                            ForEach(TimeRange.allCases, id: \.self) {
                                Text($0.displayName)
                                    .font(.nunitoRegular(size: 14))
                            }
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Text("\(String.Home.sliderCount) \(Int(count))")
                        .font(.nunitoRegular(size: 14))
                    HStack(spacing: Constants.smallSpacing) {
                        Text("1")
                            .font(.nunitoRegular(size: 12))
                            .foregroundColor(.white)
                            .padding(7)
                            .background {
                                Color.purple900
                                    .mask(Circle())
                            }
                        Slider(value: $count, in: 1...50)
                        Text("50")
                            .font(.nunitoRegular(size: 12))
                            .foregroundColor(.white)
                            .padding(4)
                            .background {
                                Color.purple900
                                    .mask(Circle())
                            }
                    }
                }
                
                ForEach(Array(data), id: \.offset) { dataElement in
                    dataRowView(dataElement, optionsAction)
                        .onTapGesture {
                            action(dataElement.element)
                        }
                }
            }
        }
        .padding(Constants.margin)
        .cardBackground(borderColor: .gray400, hasShadow: false)
        .padding(.horizontal, Constants.margin)
    }
}
