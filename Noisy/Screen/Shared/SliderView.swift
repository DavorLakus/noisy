//
//  SliderView.swift
//  Noisy
//
//  Created by Davor Lakus on 31.07.2023..
//

import SwiftUI

struct SliderView: View {
    @Binding var value: Double
    let min: Double
    let max: Double
    
    init(value: Binding<Double>, min: Double = 1, max: Double = 50) {
        _value = value
        self.min = min
        self.max = max
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(String.Home.sliderCount) \(Int(value))")
                .font(.nunitoSemiBold(size: 14))
                .foregroundColor(.gray700)
            
            HStack(spacing: Constants.smallSpacing) {
                Text("\(Int(min))")
                    .font(.nunitoRegular(size: 12))
                    .foregroundColor(.gray700)
                Slider(value: $value, in: min...max)
                Text("\(Int(max))")
                    .font(.nunitoRegular(size: 12))
                    .foregroundColor(.gray700)
            }
        }
    }
}

struct SimpleSliderView: View {
    @Binding var limit: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(String.Home.sliderCount) \(Int(limit))")
                .font(.nunitoRegular(size: 14))
            HStack(spacing: Constants.smallSpacing) {
                Text("\(Int(range.lowerBound))")
                    .font(.nunitoRegular(size: 12))
                    .foregroundColor(.white)
                    .padding(7)
                    .background {
                        Color.purple900
                            .mask(Circle())
                    }
                Slider(value: $limit, in: range)
                Text("\(Int(range.upperBound))")
                    .font(.nunitoRegular(size: 12))
                    .foregroundColor(.white)
                    .padding(4)
                    .background {
                        Color.purple900
                            .mask(Circle())
                    }
            }
        }
    }
}
