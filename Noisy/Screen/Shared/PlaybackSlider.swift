//
//  PlaybackSlider.swift
//  Noisy
//
//  Created by Davor Lakus on 10.08.2023..
//

import SwiftUI

struct PlaybackSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    @State var width: CGFloat = .zero
    let isSliding: (Bool) -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray500)
                .frame(height: 4)
                .frame(maxWidth: .infinity)
                .readSize { width = $0.width }
                .onTapGesture {
                    isSliding(true)
                    value = ($0.x - 10) / width * range.upperBound
                    isSliding(false)
                }
            
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.green400)
                .frame(height: 5)
                .frame(width: width * value / range.upperBound, height: 5)
                .onTapGesture {
                    isSliding(true)
                    value = ($0.x - 10) / width * range.upperBound
                    isSliding(false)

                }
                
            Circle()
                .fill(Color.orange100)
                .frame(width: 20, height: 20)
                .padding(.trailing, 5)
                .offset(x: (width - 10) * value / range.upperBound)
                .gesture(
                    DragGesture()
                        .onChanged { dragValue in
                            isSliding(true)
                            if (10...width).contains(dragValue.location.x) {
                                value = (dragValue.location.x - 10) / width * range.upperBound
                            }
                        }
                        .onEnded { _ in
                            isSliding(false)
                            if value < 0 {
                                value = 0
                            }
                            if value > range.upperBound {
                                value = range.upperBound - 0.5
                            }
                        }
                )
        }
    }
}
