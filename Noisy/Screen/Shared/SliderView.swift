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
                    .foregroundColor(.gray500)
                Slider(value: $value, in: min...max)
                Text("\(Int(max))")
                    .font(.nunitoRegular(size: 12))
                    .foregroundColor(.gray500)
            }
        }
    }
}
